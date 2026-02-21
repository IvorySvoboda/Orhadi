//
//  ArchivedTodoRow.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 05/05/25.
//

import SwiftUI

struct ArchivedTodoRow: View {
    @Environment(ArchivedTodosView.ViewModel.self) private var vm
    let todo: ToDo

    var body: some View {
        todoLabel
            .swipeActions(edge: .leading) {
                unarchiveButton(destructive: true).tint(.teal)
            }
            .swipeActions(edge: .trailing) {
                deleteButton(destructive: true)
            }
            .contextMenu {
                unarchiveButton()
                deleteButton(destructive: true)
            }
    }

    // MARK: - To-Do Label

    private var todoLabel: some View {
        HStack {
            todoStatus
            VStack(alignment: .leading) {
                HStack {
                    todoPriority
                    todoTitle
                }.frame(maxWidth: 300, alignment: .leading)

                CustomLabel("\(todo.dueDate.friendlyDateString)", systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - To-Do Status

    @ViewBuilder private var todoStatus: some View {
        if todo.isCompleted {
            Image(systemName: "checkmark")
                .foregroundStyle(Color.accentColor)
        } else if todo.dueDate < .now {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
        }
    }

    // MARK: - To-Do Priority

    @ViewBuilder private var todoPriority: some View {
        if todo.priority.rawValue > 0 {
            Image(systemName: todo.priority.symbolName)
                .font(.subheadline)
                .foregroundStyle(todo.isCompleted ? Color.secondary : Color.orange)
                .frame(width: 5, alignment: .center)
                .padding(.leading, 2.5)
        }
    }

    // MARK: - To-Do Title

    private var todoTitle: some View {
        Text(todo.title.nilIfEmpty() ?? String(localized: "Not provided"))
            .titleStyle()
            .foregroundStyle(todo.isCompleted ? Color.secondary : Color.font)
    }

    // MARK: - Action Buttons

    private func unarchiveButton(destructive: Bool = false) -> some View {
        Button("Restore", systemImage: "gobackward", role: destructive ? .destructive : nil) {
            try? vm.unarchiveToDo(todo)
        }
    }

    private func deleteButton(destructive: Bool = false) -> some View {
        Button("Delete", systemImage: "trash.fill", role: destructive ? .destructive : nil) {
            try? vm.softDeleteToDo(todo)
        }.tint(.red)
    }
}
