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
    @State private var vm = ViewModel(dataManager: .shared)

    // MARK: - Views

    var body: some View {
        List(selection: $vm.selectedToDos) {
            Section {} footer: {
                Text("The to-dos remain available here for 30 days. After this period, they will be permanently deleted.")
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity)
            }

            Section {
                ForEach(vm.deletedToDos) { todo in
                    DeletedTodosRow(todo: todo)
                        .tag(todo)
                }
            }
        }
        .environment(vm)
        .navigationTitle("Deleted To-Dos")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.visible, for: .bottomBar)
        .toolbarVisibility(editMode?.wrappedValue.isEditing == true ? .visible : .hidden, for: .bottomBar)
        .toolbarVisibility(editMode?.wrappedValue.isEditing == true && .iOS26 ? .hidden : .visible, for: .tabBar)
        .toolbar { toolbarComponents }
        .onChange(of: vm.deletedToDos) { _, newTodos in
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
            Button(vm.selectedToDos.isEmpty ? "Restore All" : "Restore") {
                vm.restoreToDos()
            }

            Spacer()

            Button(vm.selectedToDos.isEmpty ? "Delete All" : "Delete") {
                vm.showDeleteConfirmation.toggle()
            }
            .confirmationDialog(vm.deleteMessageText, isPresented: $vm.showDeleteConfirmation, titleVisibility: .visible) {
                Button(vm.deleteActionTitle, role: .destructive) {
                    vm.deleteToDos()
                }
            }
        }
    }
}
