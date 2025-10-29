//
//  ToDoRowView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 01/05/25.
//

import SwiftUI

struct ToDoRowView: View {

    let todo: ToDo
    let onEdit: () -> Void
    let onComplete: () -> Void
    let onArchive: () -> Void
    let onDelete: () -> Void

    // MARK: - Views

    var body: some View {
        DisclosureGroup {
            if !todo.info.characters.isEmpty {
                Text(todo.info)
            } else {
                Text("Not specified.")
                    .foregroundStyle(Color.secondary)
            }
        } label: {
            TimelineView(.everyMinute) { _ in
                HStack {
                    if todo.isCompleted {
                        Image(systemName: "checkmark")
                            .foregroundStyle(Color.accentColor)
                    }

                    if !todo.isCompleted, todo.dueDate < .now {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                    }

                    todoBaseInfos
                }
            }
            .swipeActions(edge: .leading) {
                Button(role: .destructive) {
                    onComplete()
                } label: {
                    if todo.isCompleted {
                        Label("Uncomplete", systemImage: "minus")
                    } else {
                        Label("Complete", systemImage: "checkmark")
                    }
                }.tint(.accentColor)
            }
            .swipeActions(edge: .trailing) {
                Button("Delete", systemImage: "trash.fill", role: .destructive) {
                    onDelete()
                }

                Button("Archive", systemImage: "archivebox.fill", role: .destructive) {
                    onArchive()
                }.tint(.teal)

                Button("Edit", systemImage: "pencil") {
                    onEdit()
                }.tint(Color.accentColor)
            }
            .contextMenu {
                Button {
                    onComplete()
                } label: {
                    if todo.isCompleted {
                        Label("Uncomplete", systemImage: "minus")
                    } else {
                        Label("Complete", systemImage: "checkmark")
                    }
                }

                Button("Edit", systemImage: "pencil") {
                    onEdit()
                }

                Button("Archive", systemImage: "archivebox.fill") {
                    onArchive()
                }

                Button("Delete", systemImage: "trash.fill", role: .destructive) {
                    onDelete()
                }
            }
        }
    }

    private var todoBaseInfos: some View {
        VStack(alignment: .leading) {
            HStack {
                if todo.priority.rawValue > 0 {
                    Image(systemName: "exclamationmark\(todo.priority.rawValue > 1 ? ".\(todo.priority.rawValue)" : "")")
                        .font(.subheadline)
                        .foregroundStyle(todo.isCompleted ? Color.secondary : Color.orange)
                        .frame(width: 5, alignment: .center)
                        .padding(.leading, 2.5)
                }

                Text(todo.title.nilIfEmpty() ?? String(localized: "Not specified"))
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundStyle(todo.isCompleted ? Color.secondary : Color.font)
            }.frame(maxWidth: 300, alignment: .leading)

            CustomLabel("\(todo.formattedDueDate)", systemImage: "calendar")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
