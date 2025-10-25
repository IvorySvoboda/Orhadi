//
//  DeletedSubjectsView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 05/05/25.
//

import SwiftUI
import SwiftData
import WidgetKit

struct DeletedSubjectsView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode
    @State private var viewModel = ViewModel()

    // MARK: - Views

    var body: some View {
        List(selection: $viewModel.selectedSubjects) {
            Section {} footer: {
                Text("The subjects remain available here for 30 days. After this period, they will be permanently deleted.")
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity)
            }

            Section {
                ForEach(viewModel.deletedSubjects) { subject in
                    DeletedSubjectRowView(subject: subject, showConflictAlert: { viewModel.showConflictAlert.toggle() })
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
                Button(viewModel.selectedSubjects.isEmpty ? "Restore All" : "Restore") {
                    viewModel.restoreSubjects()
                }

                Spacer()

                Button(viewModel.selectedSubjects.isEmpty ? "Delete All" : "Delete") {
                    viewModel.showDeleteConfirmation.toggle()
                }
                .confirmationDialog(viewModel.deleteMessageText, isPresented: $viewModel.showDeleteConfirmation, titleVisibility: .visible) {
                    Button(viewModel.deleteActionTitle, role: .destructive) {
                        viewModel.deleteSubjects()
                    }
                }
            }
        }
        .alert("Conflict Detected!", isPresented: $viewModel.showConflictAlert) {
            Button("Close") {
                viewModel.conflictingSubjects = []
            }
        } message: {
            Text(viewModel.conflictMessageText)
        }
        .onChange(of: viewModel.deletedSubjects) { _, _ in
            if viewModel.deletedSubjects.isEmpty {
                dismiss()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: ModelContext.didSave)) { _ in
            viewModel.fetchDeletedSubjects()
        }
        .onAppear {
            if viewModel.context == nil {
                viewModel.context = context
                viewModel.fetchDeletedSubjects()
            }
        }
    }
}
