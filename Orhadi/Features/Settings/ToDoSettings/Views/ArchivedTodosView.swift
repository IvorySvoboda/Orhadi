//
//  ArchivedTodosView.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 05/05/25.
//

import SwiftUI
import SwiftData
import WidgetKit

struct ArchivedTodosView: View {
    @Environment(Settings.self) private var settings
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode

    @Query(filter: #Predicate<ToDo> {
        $0.isArchived && !$0.isToDoDeleted
    }, sort: \.createdAt, animation: .smooth) private var archivedTodos: [ToDo]

    @State private var selectedTodos = Set<ToDo>()

    // MARK: - Views

    var body: some View {
        List(selection: $selectedTodos) {
            ForEach(archivedTodos) { todo in
                ArchivedTodoRowView(todo: todo)
                    .tag(todo)
            }
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
                Button(selectedTodos.isEmpty ? "Unarchive All" : "Unarchive") {
                    unarchiveToDos()
                }

                Spacer()

                Button(selectedTodos.isEmpty ? "Delete All" : "Delete") {
                    deleteToDos()
                }
            }
        }
        .onChange(of: archivedTodos) { _, newTodos in
            if newTodos.isEmpty {
                dismiss()
            }

            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    // MARK: - Actions

    private func deleteToDos() {
        if selectedTodos.isEmpty {
            for todo in archivedTodos {
                withAnimation {
                    todo.isToDoDeleted = true
                    todo.deletedAt = .now
                }
            }
        } else {
            for todo in selectedTodos {
                withAnimation {
                    todo.isToDoDeleted = true
                    todo.deletedAt = .now
                }
            }
            selectedTodos.removeAll()

        }
    }

    private func unarchiveToDos() {
        if selectedTodos.isEmpty {
            for todo in archivedTodos {
                todo.unarchive(scheduleNotifications: settings.scheduleNotifications)
            }
        } else {
            for todo in selectedTodos {
                todo.unarchive(scheduleNotifications: settings.scheduleNotifications)
            }
            selectedTodos.removeAll()
        }
    }
}
