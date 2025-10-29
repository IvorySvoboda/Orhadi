//
//  ArchivedTodosView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 05/05/25.
//

import SwiftUI
import SwiftData

struct ArchivedTodosView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode
    @State private var viewModel = ViewModel(dataManager: .shared)

    // MARK: - Views

    var body: some View {
        List(viewModel.archivedToDos, selection: $viewModel.selectedToDos) { todo in
            ArchivedTodoRowView(
                todo: todo,
                onUnarchive: { try? viewModel.unarchiveToDo(todo) },
                onDelete: { try? viewModel.softDeleteToDo(todo) }
            )
            .tag(todo)
        }
        .navigationTitle("Archived To-Dos")
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
                Button(viewModel.selectedToDos.isEmpty ? "Unarchive All" : "Unarchive") {
                    viewModel.unarchiveToDos()
                }

                Spacer()

                Button(viewModel.selectedToDos.isEmpty ? "Delete All" : "Delete") {
                    viewModel.deleteToDos()
                }
            }
        }
        .onChange(of: viewModel.archivedToDos) { _, newTodos in
            if newTodos.isEmpty {
                dismiss()
            }
        }
    }
}
