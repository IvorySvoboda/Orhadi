//
//  DeletedSubjectsView.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 05/05/25.
//

import SwiftUI
import SwiftData
import WidgetKit

struct DeletedSubjectsView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode

    @Query(filter: #Predicate<Subject> { $0.isSubjectDeleted }, sort: \.deletedAt, animation: .smooth)
    private var deletedSubjects: [Subject]

    @State private var selectedSubjects = Set<Subject>()
    @State private var conflictingSubjects: [Subject] = []
    @State private var showDeleteConfirmation = false
    @State private var showConflictAlert = false

    // MARK: - Computed helpers

    private var countToActOn: Int {
        selectedSubjects.isEmpty ? deletedSubjects.count : selectedSubjects.count
    }

    private var isPlural: Bool {
        countToActOn > 1
    }

    private var deleteActionTitle: LocalizedStringKey {
        if isPlural {
            return "Delete \(countToActOn) Subjects"
        } else {
            return "Delete Subject"
        }
    }

    private var deleteMessageText: LocalizedStringKey {
        if isPlural {
            return "These \(countToActOn) subjects will be deleted. This action cannot be undone."
        } else {
            return "This subject will be deleted. This action cannot be undone."
        }
    }

    private var conflictMessageText: LocalizedStringKey {
        if conflictingSubjects.count > 1 {
            return "Some of the subjects are conflicting with existing subjects. Please adjust them before recovering."
        } else {
            return "The selected subject conflicts with an existing subject. Please adjust it before recovering."
        }
    }

    // MARK: - Views

    var body: some View {
        List(selection: $selectedSubjects) {
            Section {} footer: {
                Text("The subjects remain available here for 30 days. After this period, they will be permanently deleted.")
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity)
            }

            Section {
                ForEach(deletedSubjects) { subject in
                    DeletedSubjectRowView(subject: subject, showConflictAlert: { showConflictAlert.toggle() })
                        .tag(subject)
                }
            }
        }
        .navigationTitle("Deleted Subjects")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.visible, for: .bottomBar)
        .toolbarBackground(Color.orhadiBG, for: .bottomBar)
        .toolbarVisibility(editMode?.wrappedValue.isEditing == true ? .visible : .hidden, for: .bottomBar)
        .toolbarVisibility(editMode?.wrappedValue.isEditing == true && .iOS26 ? .hidden : .visible, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }

            ToolbarItemGroup(placement: .bottomBar) {
                Button(selectedSubjects.isEmpty ? "Restore All" : "Restore") {
                    restoreSubjects()
                }

                Spacer()

                Button(selectedSubjects.isEmpty ? "Delete All" : "Delete") {
                    showDeleteConfirmation.toggle()
                }
                .confirmationDialog(deleteMessageText, isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                    Button(deleteActionTitle, role: .destructive) {
                        deleteSubjects()
                    }
                }
            }
        }
        .alert("Conflict Detected!", isPresented: $showConflictAlert) {
            Button("Close") {
                conflictingSubjects = []
            }
        } message: {
            Text(conflictMessageText)
        }
        .onChange(of: deletedSubjects) { _, newSubjects in
            WidgetCenter.shared.reloadAllTimelines()

            if newSubjects.isEmpty {
                dismiss()
            }
        }
        .onAppear {
            cleanExpiredSubjects()
        }
    }

    // MARK: - Actions

    private func cleanExpiredSubjects() {
        for subject in deletedSubjects {
            guard let removalDate = Calendar.current.date(byAdding: .day, value: 30, to: subject.deletedAt ?? .now), removalDate <= .now else {
                continue
            }

            withTransaction(Transaction(animation: nil)) {
                context.delete(subject)
            }
        }
    }

    // MARK: Delete Actions

    private func deleteSubjects() {
        if selectedSubjects.isEmpty {
            for subject in deletedSubjects {
                withAnimation { context.delete(subject) }
            }
        } else {
            for subject in selectedSubjects {
                withAnimation { context.delete(subject) }
            }
            selectedSubjects.removeAll()
        }
    }

    // MARK: Restore Actions

    private func restoreSubjects() {
        if selectedSubjects.isEmpty {
            for subject in deletedSubjects {
                let hasConflictWithOthersSubjects = SubjectConflictVerifier.hasConflictWithOtherSubjects(
                    id: subject.id,
                    start: subject.startTime,
                    end: subject.endTime,
                    schedule: subject.schedule,
                    context:  context
                )

                if hasConflictWithOthersSubjects {
                    conflictingSubjects.append(subject)
                } else {
                    subject.restore()
                }
            }

            if !conflictingSubjects.isEmpty {
                showConflictAlert.toggle()
            }
        } else {
            for subject in selectedSubjects {
                let hasConflictWithOthersSubjects = SubjectConflictVerifier.hasConflictWithOtherSubjects(
                    id: subject.id,
                    start: subject.startTime,
                    end: subject.endTime,
                    schedule: subject.schedule,
                    context:  context
                )

                if hasConflictWithOthersSubjects {
                    conflictingSubjects.append(subject)
                } else {
                    subject.restore()
                }
            }

            selectedSubjects.removeAll()

            if !conflictingSubjects.isEmpty {
                showConflictAlert.toggle()
            }
        }
    }
}
