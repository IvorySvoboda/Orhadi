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
    /// Delete Confirmation
    @State private var showDeleteAllConfirmation = false
    @State private var showDeleteSelectedConfirmation = false
    /// Conflicts Alert
    @State private var showConflictAlert = false

    var canHideTabBar: Bool {
        if #available(iOS 26, *) {
            return false
        } else {
            return true
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
                    DeletedSubjectRowView(subject: subject)
                        .tag(subject)
                }
            }
        }
        .navigationTitle("Deleted Subjects")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.visible, for: .bottomBar)
        .toolbarBackground(Color.orhadiBG, for: .bottomBar)
        .toolbarVisibility(editMode?.wrappedValue.isEditing == true ? .visible : .hidden, for: .bottomBar)
        /// Oculta a TabBar no iOS 26+
        .toolbarVisibility(editMode?.wrappedValue.isEditing == true && !canHideTabBar ? .hidden : .visible, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }

            ToolbarItemGroup(placement: .bottomBar) {
                Button(selectedSubjects.isEmpty ? "Restore All" : "Restore") {
                    selectedSubjects.isEmpty ? restoreAllSubjects() : restoreSelectedSubjects()
                }
                .alert("Conflict Detected!", isPresented: $showConflictAlert) {
                    Button("Close") {
                        conflictingSubjects = []
                    }
                } message: {
                    VStack(spacing: 10) {
                        if conflictingSubjects.count > 1 {
                            Text("Some of the subjects are conflicting with existing subjects. Please adjust them before recovering.")
                        } else {
                            Text("The selected subject conflicts with an existing subject. Please adjust it before recovering.")
                        }
                    }
                }

                Spacer()

                Button(selectedSubjects.isEmpty ? "Delete All" : "Delete") {
                    selectedSubjects.isEmpty ? showDeleteAllConfirmation.toggle() : showDeleteSelectedConfirmation.toggle()
                }
                .confirmationDialog(
                    deletedSubjects.count > 1 ? "These \(deletedSubjects.count) subjects will be deleted. This action cannot be undone." : "This subject will be deleted. This action cannot be undone.",
                    isPresented: $showDeleteAllConfirmation,
                    titleVisibility: .visible
                ) {
                    Button(role: .destructive) {
                        deleteAllSubjects()
                    } label: {
                        Text(deletedSubjects.count > 1 ? "Delete \(deletedSubjects.count) Subjects" : "Delete Subject")
                    }
                }
                .confirmationDialog(
                    selectedSubjects.count > 1 ? "These \(selectedSubjects.count) subjects will be deleted. This action cannot be undone." : "This subject will be deleted. This action cannot be undone.",
                    isPresented: $showDeleteSelectedConfirmation,
                    titleVisibility: .visible
                ) {
                    Button(role: .destructive) {
                        deleteSelectedSubjects()
                    } label: {
                        Text(selectedSubjects.count > 1 ? "Delete \(selectedSubjects.count) Subjects" : "Delete Subject")
                    }
                }
            }
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

    private func deleteAllSubjects() {
        for subject in deletedSubjects {
            withAnimation { context.delete(subject) }
        }
    }

    private func deleteSelectedSubjects() {
        for subject in selectedSubjects {
            withAnimation { context.delete(subject) }
        }
        selectedSubjects.removeAll()
    }

    private func restoreAllSubjects() {
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
                restore(subject)
            }
        }
        
        if !conflictingSubjects.isEmpty {
            showConflictAlert.toggle()
        }
    }

    private func restoreSelectedSubjects() {
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
                restore(subject)
            }
        }
        
        selectedSubjects.removeAll()

        if !conflictingSubjects.isEmpty {
            showConflictAlert.toggle()
        }
    }

    private func restore(_ subject: Subject) {
        withAnimation {
            subject.isSubjectDeleted = false
            subject.deletedAt = nil
        }
    }
}
