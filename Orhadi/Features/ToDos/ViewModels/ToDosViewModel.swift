//
//  ToDosViewModel.swift
//  Orhadi
//
//  Created by Zyvoxi . on 26/04/25.
//

import SwiftUI

@Observable
final class ToDosViewModel {
    private var allTodos: [ToDo] = []
    private var gracePeriod: TimeInterval = 0

    var showPendingSection: Bool = false
    var showUpcomingSection: Bool = false
    var showCompletedSection: Bool = false
    var todoToAdd: ToDo? = nil
    var todoToEdit: ToDo? = nil

    var pendingTodos: [ToDo] {
        allTodos.filter {
            $0.dueDate < .now
                && $0.dueDate.addingTimeInterval(gracePeriod) > .now
                && !$0.isCompleted
        }
    }

    var upcomingTodos: [ToDo] {
        allTodos.filter {
            $0.dueDate > .now && !$0.isCompleted
        }
    }

    var completedOrExpiredTodos: [ToDo] {
        allTodos
            .filter {
                $0.dueDate.addingTimeInterval(gracePeriod) < .now
                    || $0.isCompleted
            }
            .sorted { $0.dueDate > $1.dueDate }
    }

    // MARK: - Actions

    func updateTodos(_ todos: [ToDo], gracePeriod: TimeInterval) {
        self.allTodos = todos
        self.gracePeriod = gracePeriod
        updateSectionVisibility()
    }

    func addNewTodo() {
        todoToAdd = ToDo()
    }

    func updateSectionVisibility() {
        showPendingSection = !pendingTodos.isEmpty
        showUpcomingSection = !upcomingTodos.isEmpty
        showCompletedSection = !completedOrExpiredTodos.isEmpty
    }
}
