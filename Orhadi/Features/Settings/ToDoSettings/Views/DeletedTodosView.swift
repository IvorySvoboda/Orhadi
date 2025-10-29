//
//  DeletedTodosView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 05/05/25.
//

import SwiftUI
import SwiftData
import WidgetKit

struct DeletedTodosView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode
    @State private var viewModel = ViewModel(dataManager: .shared)

    // MARK: - Views

    var body: some View {
        List(selection: $viewModel.selectedToDos) {
            Section {} footer: {
                Text("The to-dos remain available here for 30 days. After this period, they will be permanently deleted.")
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity)
            }

            Section {
                ForEach(viewModel.deletedToDos) { todo in
                    DeletedTodosRowView(
                        todo: todo,
                        onRestore: { try? viewModel.restoreToDo(todo) },
                        onDelete: { try? viewModel.hardDeleteToDo(todo) }
                    )
                    .tag(todo)
                }
            }
        }
        .navigationTitle("Deleted To-Dos")
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
                Button(viewModel.selectedToDos.isEmpty ? "Restore All" : "Restore") {
                    viewModel.restoreToDos()
                }

                Spacer()

                Button(viewModel.selectedToDos.isEmpty ? "Delete All" : "Delete") {
                    viewModel.showDeleteConfirmation.toggle()
                }
                .confirmationDialog(viewModel.deleteMessageText, isPresented: $viewModel.showDeleteConfirmation, titleVisibility: .visible) {
                    Button(viewModel.deleteActionTitle, role: .destructive) {
                        viewModel.deleteToDos()
                    }
                }
            }
        }
        .onChange(of: viewModel.deletedToDos) { _, newTodos in
            if newTodos.isEmpty {
                dismiss()
            }
        }
    }
}
