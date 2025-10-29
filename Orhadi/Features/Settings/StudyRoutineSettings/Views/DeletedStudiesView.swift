//
//  DeletedStudyView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 05/05/25.
//

import SwiftUI
import SwiftData

struct DeletedStudiesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode
    @State private var viewModel = ViewModel(dataManager: .shared)

    // MARK: - Views

    var body: some View {
        List(selection: $viewModel.selectedStudies) {
            Section {} footer: {
                Text("The studies remain available here for 30 days. After this period, they will be permanently deleted.")
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity)
            }

            Section {
                ForEach(viewModel.deletedStudies) { study in
                    DeletedStudyRowView(
                        study: study,
                        onRestore: { try? viewModel.restoreStudy(study) },
                        onDelete: { try? viewModel.hardDeleteStudy(study) }
                    )
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
                Button(viewModel.selectedStudies.isEmpty ? "Restore All" : "Restore") {
                    viewModel.restoreStudies()
                }

                Spacer()

                Button(viewModel.selectedStudies.isEmpty ? "Delete All" : "Delete") {
                    viewModel.showDeleteConfirmation.toggle()
                }
                .confirmationDialog(viewModel.deleteMessageText, isPresented: $viewModel.showDeleteConfirmation, titleVisibility: .visible) {
                    Button(viewModel.deleteActionTitle, role: .destructive) {
                        viewModel.deleteStudies()
                    }
                }
            }
        }
        .onChange(of: viewModel.deletedStudies) { _, newStudies in
            if newStudies.isEmpty {
                dismiss()
            }
        }
    }
}
