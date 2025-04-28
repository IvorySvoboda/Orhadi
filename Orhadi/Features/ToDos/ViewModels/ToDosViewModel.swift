//
//  ToDosViewModel.swift
//  Orhadi
//
//  Created by Zyvoxi . on 26/04/25.
//

import SwiftUI
import SwiftData

@Observable
final class ToDosViewModel {
    // MARK: - Properties

    private(set) var allTodos: [ToDo] = []
    private var timer: Timer? = nil

    var showPendingSection: Bool = false
    var showOverdueSection: Bool = false
    var showCompletedSection: Bool = false
    var todoToAdd: ToDo? = nil
    var todoToEdit: ToDo? = nil

    // MARK: - Computed Properties

    var overdueTodos: [ToDo] {
        allTodos.filter {
            $0.dueDate < Date() && !$0.isCompleted
        }
    }

    var pendingTodos: [ToDo] {
        allTodos.filter {
            $0.dueDate > .now && !$0.isCompleted
        }
    }

    var completedTodos: [ToDo] {
        allTodos.filter {
            $0.isCompleted
        }
    }

    // MARK: - Actions

    func updateTodos(_ todos: [ToDo]) {
        withAnimation {
            self.allTodos = todos
            updateSectionVisibility()
        }
    }

    func addNewTodo() {
        todoToAdd = ToDo()
    }

    func updateSectionVisibility() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation {
                self.showPendingSection = !self.pendingTodos.isEmpty
                self.showOverdueSection = !self.overdueTodos.isEmpty
                self.showCompletedSection = !self.completedTodos.isEmpty
            }
        }
    }

    func startUpdatingTodos() {
        /// pré atualiza
        self.updateTodos(self.allTodos)

        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            self.updateTodos(self.allTodos)
        }
    }

    func stopUpdatingTodos() {
        timer?.invalidate()
    }

    func deleteTodo(_ todo: ToDo, using context: ModelContext) {
        let todoID = todo.id
        let identifiers = [
            "\(todoID)-1h",
            "\(todoID)-24h",
            "\(todoID)-due",
        ]

        NotificationsManager.shared.removePendingNotifications(withIdentifiers: identifiers)

        self.updateTodos(self.allTodos.filter { $0 != todo })

        withAnimation {
            context.delete(todo)
        }
    }
}
