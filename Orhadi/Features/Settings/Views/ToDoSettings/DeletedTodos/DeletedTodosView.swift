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
    @Environment(Settings.self) private var settings

    @Query(filter: #Predicate<ToDo> { $0.isToDoDeleted }, sort: \.deletedAt, animation: .smooth)
    private var deletedTodos: [ToDo]

    @State private var selectedTodos = Set<ToDo>()
    @State private var showDeleteConfirmation = false

    // MARK: - Computed helpers

    private var countToActOn: Int {
        selectedTodos.isEmpty ? deletedTodos.count : selectedTodos.count
    }

    private var isPlural: Bool {
        countToActOn > 1
    }

    private var deleteActionTitle: LocalizedStringKey {
        if isPlural {
            return "Delete \(countToActOn) To-Dos"
        } else {
            return "Delete To-Do"
        }
    }

    private var deleteMessageText: LocalizedStringKey {
        if isPlural {
            return "These \(countToActOn) to-dos will be deleted. This action cannot be undone."
        } else {
            return "This to-do will be deleted. This action cannot be undone."
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
                Button(selectedTodos.isEmpty ? "Restore All" : "Restore") {
                    restoreToDos()
                }

                Spacer()

                Button(selectedTodos.isEmpty ? "Delete All" : "Delete") {
                    showDeleteConfirmation.toggle()
                }
                .confirmationDialog(deleteMessageText, isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                    Button(deleteActionTitle, role: .destructive) {
                        deleteToDos()
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

    private func deleteToDos() {
        if selectedTodos.isEmpty {
            for todo in deletedTodos {
                withAnimation { context.delete(todo) }
            }
        } else {
            for todo in selectedTodos {
                withAnimation { context.delete(todo) }
            }
            selectedTodos.removeAll()
        }
    }

    private func restoreToDos() {
        if selectedTodos.isEmpty {
            for todo in deletedTodos {
                todo.restore(scheduleNotifications: settings.scheduleNotifications)
            }
        } else {
            for todo in selectedTodos {
                todo.restore(scheduleNotifications: settings.scheduleNotifications)
            }
            selectedTodos.removeAll()
        }
    }
}
