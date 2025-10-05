//
//  ArchivedTodoRowView.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 05/05/25.
//

import SwiftUI

struct ArchivedTodoRowView: View {

    var todo: ToDo

    var body: some View {
        HStack {
            if todo.isCompleted {
                Image(systemName: "checkmark")
                    .foregroundStyle(Color.accentColor)
            }

            if !todo.isCompleted, todo.dueDate < .now {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
            }

            VStack(alignment: .leading) {
                HStack {
                    if todo.priority.rawValue > 0 {
                        Image(systemName: "exclamationmark\(todo.priority.rawValue > 1 ? ".\(todo.priority.rawValue)" : "")")
                            .font(.subheadline)
                            .foregroundStyle(todo.isCompleted ? Color.secondary : Color.orange)
                            .frame(width: 5, alignment: .center)
                            .padding(.leading, 2.5)
                    }

                    Text(todo.title.nilIfEmpty() ?? String(localized: "Not provided"))
                        .font(.headline)
                        .lineLimit(1)
                        .foregroundStyle(todo.isCompleted ? Color.secondary : Color.font)
                }
                .frame(maxWidth: 300, alignment: .leading)

                CustomLabel("\(todo.formattedDueDate)", systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        
        .swipeActions(edge: .leading) {
            Button(role: .destructive) {
                Task {
                    unarchiveTodo()
                }
            } label: {
                Label("Unarchive", systemImage: "archivebox.fill")
                    .labelStyle(.iconOnly)
            }.tint(.teal)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                Task {
                    deleteToDo()
                }
            } label: {
                Label("Delete", systemImage: "trash.fill")
                    .labelStyle(.iconOnly)
            }
        }
        .contextMenu {
            Button {
                Task {
                    unarchiveTodo()
                }
            } label: {
                Label("Unarchive", systemImage: "archivebox.fill")
            }

            Button(role: .destructive) {
                Task {
                    deleteToDo()
                }
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
        }
    }

    private func unarchiveTodo() {
        if !todo.isCompleted, todo.dueDate > .now {
            todo.scheduleNotification()
        }

        withAnimation {
            todo.isArchived = false
        }
    }

    private func deleteToDo() {
        withAnimation {
            todo.isToDoDeleted = true
            todo.deletedAt = .now
        }
    }
}
