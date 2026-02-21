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
    @State private var vm = ViewModel(dataManager: .shared)

    // MARK: - Views

    var body: some View {
        List(vm.archivedToDos, selection: $vm.selectedToDos) { todo in
            ArchivedTodoRow(todo: todo)
                .tag(todo)
        }
        .environment(vm)
        .navigationTitle("Archived To-Dos")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.visible, for: .bottomBar)
        .toolbarVisibility(editMode?.wrappedValue.isEditing == true ? .visible : .hidden, for: .bottomBar)
        .toolbarVisibility(editMode?.wrappedValue.isEditing == true && .iOS26 ? .hidden : .visible, for: .tabBar)
        .toolbar { toolbarComponents }
        .onChange(of: vm.archivedToDos) { _, newTodos in
            if newTodos.isEmpty {
                dismiss()
            }
        }
    }

    // MARK: - Toolbar Components

    @ToolbarContentBuilder
    private var toolbarComponents: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            EditButton()
        }

        ToolbarItemGroup(placement: .bottomBar) {
            Button(vm.selectedToDos.isEmpty ? "Unarchive All" : "Unarchive") {
                vm.unarchiveToDos()
            }

            Spacer()

            Button(vm.selectedToDos.isEmpty ? "Delete All" : "Delete") {
                vm.deleteToDos()
            }
        }
    }
}
