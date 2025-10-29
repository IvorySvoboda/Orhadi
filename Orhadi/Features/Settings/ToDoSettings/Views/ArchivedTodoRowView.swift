//
//  ArchivedTodoRowView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 05/05/25.
//

import SwiftUI

struct ArchivedTodoRowView: View {

    let todo: ToDo
    let onUnarchive: () -> Void
    let onDelete: () -> Void

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
            Button("Unarchive", systemImage: "archivebox.fill", role: .destructive) {
                onUnarchive()
            }.tint(.teal)
        }
        .swipeActions(edge: .trailing) {
            Button("Delete", systemImage: "trash.fill", role: .destructive) {
                onDelete()
            }
        }
        .contextMenu {
            Button("Unarchive", systemImage: "archivebox.fill") {
                onUnarchive()
            }

            Button("Delete", systemImage: "trash.fill", role: .destructive) {
                onDelete()
            }
        }
    }
}
