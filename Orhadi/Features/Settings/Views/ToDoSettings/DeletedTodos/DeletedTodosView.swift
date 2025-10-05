//
//  DeletedTodosView.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 05/05/25.
//

import SwiftUI
import SwiftData
import WidgetKit

struct DeletedTodosView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode

    @Query(filter: #Predicate<ToDo> { $0.isToDoDeleted }, sort: \.deletedAt, animation: .smooth)
    private var deletedTodos: [ToDo]

    @State private var selectedTodos = Set<ToDo>()

    /// Delete Confirmation
    @State private var showDeleteAllConfirmation = false
    @State private var showDeleteSelectedConfirmation = false

    var canHideTabBar: Bool {
        if #available(iOS 26, *) {
            return false
        } else {
            return true
        }
    }

    // MARK: - Views

    var body: some View {
        List(selection: $selectedTodos) {
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
        .orhadiListStyle()
        .navigationTitle("Deleted To-Dos")
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
                Button(selectedTodos.isEmpty ? "Restore All" : "Restore") {
                    selectedTodos.isEmpty ? restoreAllTodos() : restoreSelectedTodos()
                }

                Spacer()

                Button(selectedTodos.isEmpty ? "Delete All" : "Delete") {
                    selectedTodos.isEmpty ? showDeleteAllConfirmation.toggle() : showDeleteSelectedConfirmation.toggle()
                }
                .confirmationDialog(
                    deletedTodos.count > 1 ? "These \(deletedTodos.count) to-dos will be deleted. This action cannot be undone." : "This to-do will be deleted. This action cannot be undone.",
                    isPresented: $showDeleteAllConfirmation,
                    titleVisibility: .visible
                ) {
                    Button(role: .destructive) {
                        deleteAllTodos()
                    } label: {
                        Text(deletedTodos.count > 1 ? "Delete \(deletedTodos.count) To-Dos" : "Delete To-Do")
                    }
                }
                .confirmationDialog(
                    selectedTodos.count > 1 ? "These \(selectedTodos.count) to-dos will be deleted. This action cannot be undone." : "This to-do will be deleted. This action cannot be undone.",
                    isPresented: $showDeleteSelectedConfirmation,
                    titleVisibility: .visible
                ) {
                    Button(role: .destructive) {
                        deleteSelectedTodos()
                    } label: {
                        Text(selectedTodos.count > 1 ? "Delete \(selectedTodos.count) To-Dos" : "Delete To-Do")
                    }
                }
            }
        }
        .onChange(of: deletedTodos) { _, newTodos in
            if newTodos.isEmpty {
                dismiss()
            }

            WidgetCenter.shared.reloadAllTimelines()
        }
        .onAppear {
            cleanExpiredTodos()
        }
    }

    // MARK: - Actions

    private func cleanExpiredTodos() {
        for todo in deletedTodos {
            guard let removalDate = Calendar.current.date(byAdding: .day, value: 30, to: todo.deletedAt ?? .now),
                  removalDate <= .now else { continue }

            withTransaction(Transaction(animation: nil)) {
                context.delete(todo)
            }
        }
    }

    private func deleteAllTodos() {
        for todo in deletedTodos {
            withAnimation { context.delete(todo) }
        }
    }

    private func deleteSelectedTodos() {
        for todo in selectedTodos {
            withAnimation { context.delete(todo) }
        }
        selectedTodos.removeAll()
    }

    private func restoreAllTodos() {
        for todo in deletedTodos {
            restore(todo)
        }
    }

    private func restoreSelectedTodos() {
        for todo in selectedTodos {
            restore(todo)
        }
        selectedTodos.removeAll()
    }

    private func restore(_ todo: ToDo) {
        withAnimation {
            todo.isToDoDeleted = false
            todo.deletedAt = nil
            if !todo.isCompleted, todo.dueDate > .now, !todo.isArchived {
                todo.scheduleNotification()
            }
        }
    }
}
