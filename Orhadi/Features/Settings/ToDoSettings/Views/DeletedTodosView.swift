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
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode
    @Environment(Settings.self) private var settings

    @Query(filter: #Predicate<ToDo> { $0.isToDoDeleted }, sort: \.deletedAt, animation: .smooth)
    private var deletedTodos: [ToDo]

    @State private var viewModel = ViewModel()

    // MARK: - Views

    var body: some View {
        List(selection: $viewModel.selectedToDos) {
            Section {} footer: {
                Text("The to-dos remain available here for 30 days. After this period, they will be permanently deleted.")
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity)
            }

            Section {
                ForEach(deletedTodos) { todo in
                    DeletedTodosRowView(todo: todo)
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
                    viewModel.restoreToDos(scheduleNotifications: settings.scheduleNotifications)
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
        .onChange(of: deletedTodos) { _, newTodos in
            if newTodos.isEmpty {
                dismiss()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: ModelContext.didSave)) { _ in
            viewModel.fetchDeletedToDos()
        }
        .onAppear {
            if viewModel.context == nil {
                viewModel.context = context
                viewModel.fetchDeletedToDos()
            }
        }
    }
}
