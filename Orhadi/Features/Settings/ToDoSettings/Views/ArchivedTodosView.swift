//
//  ArchivedTodosView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 05/05/25.
//

import SwiftUI
import SwiftData

struct ArchivedTodosView: View {
    @Environment(\.modelContext) private var context
    @Environment(Settings.self) private var settings
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode

    @State private var viewModel = ViewModel()

    // MARK: - Views

    var body: some View {
        List(viewModel.archivedToDos, selection: $viewModel.selectedToDos) { todo in
            ArchivedTodoRowView(todo: todo)
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
                    viewModel.unarchiveToDos(scheduleNotifications: settings.scheduleNotifications)
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
        .onReceive(NotificationCenter.default.publisher(for: ModelContext.didSave), perform: { _ in
            viewModel.fetchArchivedToDos()
        })
        .onAppear {
            if viewModel.context == nil {
                viewModel.context = context
                viewModel.fetchArchivedToDos()
            }
        }
    }
}
