//
//  ToDoRow.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 01/05/25.
//

import SwiftUI

struct ToDoRow: View {
    @Environment(ToDosView.ViewModel.self) private var vm

    let todo: ToDo

    var body: some View {
        DisclosureGroup {
            todoInfo
        } label: {
            todoLabel
        }
    }

    // MARK: - Info View

    private var todoInfo: some View {
        if !todo.info.characters.isEmpty {
            Text(todo.info)
        } else {
            Text("Not specified.")
                .foregroundStyle(Color.secondary)
        }
    }

    // MARK: - Label View

    private var todoLabel: some View {
        TimelineView(.everyMinute) { _ in
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
        .swipeActions(edge: .leading) {
            completionButton(destructive: true).tint(.accentColor)
        }
        .swipeActions(edge: .trailing) {
            deleteButton(destructive: true)
            archiveButton(destructive: true).tint(.teal)
            editButton.tint(.accentColor)
        }
        .contextMenu {
            completionButton()
            editButton
            archiveButton()
            deleteButton(destructive: true)
        }
    }

    // MARK: - Subcomponents

    @ViewBuilder private var todoStatus: some View {
        if todo.isCompleted {
            Image(systemName: "checkmark")
                .foregroundStyle(Color.accentColor)
        } else if todo.dueDate < .now {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
        }
    }

    @ViewBuilder private var todoPriority: some View {
        if todo.priority.rawValue > 0 {
            Image(systemName: todo.priority.symbolName)
                .font(.subheadline)
                .foregroundStyle(todo.isCompleted ? Color.secondary : Color.orange)
                .frame(width: 5, alignment: .center)
                .padding(.leading, 2.5)
        }
    }

    private var todoTitle: some View {
        Text(todo.title)
            .titleStyle()
            .foregroundStyle(todo.isCompleted ? Color.secondary : Color.font)
    }

    // MARK: - Action Buttons

    private func completionButton(destructive: Bool = false) -> some View {
        Button(
            todo.isCompleted ? "Uncomplete" : "Complete",
            systemImage: todo.isCompleted ? "minus" : "checkmark",
            role: destructive ? .destructive : nil
        ) {
            try? vm.toggleToDoCompleted(todo)
        }
    }

    private func deleteButton(destructive: Bool = false) -> some View {
        Button("Delete", systemImage: "trash.fill", role: destructive ? .destructive : nil) {
            try? vm.softDeleteToDo(todo)
        }
    }

    private func archiveButton(destructive: Bool = false) -> some View {
        Button("Archive", systemImage: "archivebox.fill", role: destructive ? .destructive : nil) {
            try? vm.archiveToDo(todo)
        }
    }

    private var editButton: some View {
        Button("Edit", systemImage: "pencil") {
            vm.todoToEdit = todo
        }
    }
}
