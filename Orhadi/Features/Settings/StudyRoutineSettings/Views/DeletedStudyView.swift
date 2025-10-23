//
//  DeletedStudyView.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 05/05/25.
//

import SwiftUI
import SwiftData

struct DeletedStudiesView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode

    @Query(filter: #Predicate<SRStudy> { $0.isStudyDeleted }, sort: \.deletedAt, animation: .smooth)
    private var deletedStudies: [SRStudy]

    @State private var selectedStudies = Set<SRStudy>()
    @State private var showDeleteConfirmation = false

    // MARK: - Computed helpers

    private var countToActOn: Int {
        selectedStudies.isEmpty ? deletedStudies.count : selectedStudies.count
    }

    private var isPlural: Bool {
        countToActOn > 1
    }

    private var deleteActionTitle: LocalizedStringKey {
        if isPlural {
            return "Delete \(countToActOn) Studies"
        } else {
            return "Delete Study"
        }
    }

    private var deleteMessageText: LocalizedStringKey {
        if isPlural {
            return "These \(countToActOn) studies will be deleted. This action cannot be undone."
        } else {
            return "This study will be deleted. This action cannot be undone."
        }
    }

    // MARK: - Views

    var body: some View {
        List(selection: $selectedStudies) {
            Section {} footer: {
                Text("The studies remain available here for 30 days. After this period, they will be permanently deleted.")
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity)
            }

            Section {
                ForEach(deletedStudies) { study in
                    DeletedStudyRowView(study: study)
                        .tag(study)
                }

            }
        }
        .navigationTitle("Deleted Studies")
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
                Button(selectedStudies.isEmpty ? "Restore All" : "Restore") {
                    restoreStudies()
                }

                Spacer()

                Button(selectedStudies.isEmpty ? "Delete All" : "Delete") {
                    showDeleteConfirmation.toggle()
                }
                .confirmationDialog(deleteMessageText, isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                    Button(deleteActionTitle, role: .destructive) {
                        deleteStudies()
                    }
                }
            }
        }
        .onChange(of: deletedStudies) { _, newStudies in
            if newStudies.isEmpty {
                dismiss()
            }
        }
        .onAppear {
            cleanExpiredStudies()
        }
    }

    // MARK: - Actions

    private func cleanExpiredStudies() {
        for study in deletedStudies {
            guard let removalDate = Calendar.current.date(byAdding: .day, value: 30, to: study.deletedAt ?? .now),
                  removalDate <= .now else { continue }

            withTransaction(Transaction(animation: nil)) {
                context.delete(study)
            }
        }
    }

    private func deleteStudies() {
        if selectedStudies.isEmpty {
            for study in deletedStudies {
                withAnimation { context.delete(study) }
            }
        } else {
            for study in selectedStudies {
                withAnimation { context.delete(study) }
            }
            selectedStudies.removeAll()
        }
    }

    private func restoreStudies() {
        if selectedStudies.isEmpty {
            for study in deletedStudies {
                study.restore()
            }
        } else {
            for study in selectedStudies {
                study.restore()
            }
            selectedStudies.removeAll()
        }
    }
}
