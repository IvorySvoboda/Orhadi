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
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode

    @Query(filter: #Predicate<ToDo> {
        $0.isArchived && !$0.isToDoDeleted
    }, sort: \.createdAt, animation: .smooth) private var archivedTodos: [ToDo]

    @State private var selectedTodos = Set<ToDo>()

    /// Delete Confirmation
    @State private var showDeleteAllConfirmation = false
    @State private var showDeleteSelectedConfirmation = false

    /// Restore Confirmation
    @State private var showRestoreAllConfirmation = false
    @State private var showRestoreSelectedConfirmation = false

    var canHideTabBar: Bool {
        if #available(iOS 26, *) {
            return false
        } else {
            return true
        }
    }

    var body: some View {
        List(selection: $selectedTodos) {
            ForEach(archivedTodos) { todo in
                ArchivedTodoRowView(todo: todo)
                    .tag(todo)
            }
        }
        .orhadiListStyle()
        .navigationTitle("Archived To-Dos")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.visible, for: .bottomBar)
        .toolbarBackground(Color.orhadiBG, for: .bottomBar)
        .toolbarVisibility(editMode?.wrappedValue.isEditing == true ? .visible : .hidden, for: .bottomBar)
        /// Oculta a TabBar no iOS 26+
        .toolbarVisibility(editMode?.wrappedValue.isEditing == true && !canHideTabBar ? .hidden : .visible, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }

            ToolbarItemGroup(placement: .bottomBar) {
//                HStack {
                    Button(selectedTodos.isEmpty ? "Unarchive All" : "Unarchive") {
                        selectedTodos.isEmpty ? unarchiveAllTodos() : unarchiveSelectedTodos()
                    }

                    Spacer()

                    Button(selectedTodos.isEmpty ? "Delete All" : "Delete") {
                        selectedTodos.isEmpty ? deleteAllTodos() : deleteSelectedTodos()
                    }
//                }.padding(.bottom, 5)
            }
        }
        .onChange(of: archivedTodos) { _, newTodos in
            if newTodos.isEmpty {
                dismiss()
            }

            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    private func deleteSelectedTodos() {
        for todo in selectedTodos {
            withAnimation {
                todo.isToDoDeleted = true
                todo.deletedAt = .now
            }
        }
        selectedTodos.removeAll()
    }

    private func deleteAllTodos() {
        for todo in archivedTodos {
            withAnimation {
                todo.isToDoDeleted = true
                todo.deletedAt = .now
            }
        }
    }

    private func unarchiveSelectedTodos() {
        for todo in selectedTodos {
            if !todo.isCompleted, todo.dueDate > .now {
                todo.scheduleNotification()
            }
            withAnimation {
                todo.isArchived = false
            }
        }
        selectedTodos.removeAll()
    }

    private func unarchiveAllTodos() {
        for todo in archivedTodos {
            if !todo.isCompleted, todo.dueDate > .now {
                todo.scheduleNotification()
            }
            withAnimation {
                todo.isArchived = false
            }
        }
    }
}
