//
//  ToDoRowView.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 01/05/25.
//

import SwiftUI
import MarkdownUI
import WidgetKit

struct ToDoRowView: View {
    @Environment(\.modelContext) private var context
    @Environment(Settings.self) private var settings

    let todo: ToDo
    let onEdit: () -> Void

    // MARK: - Views
    
    var body: some View {
        DisclosureGroup {
            if !todo.info.characters.isEmpty {
                if #available(iOS 26, *) {
                    Text(todo.info)
                } else {
                    Markdown("\(todo.info.characters)")
                        .orhadiMarkdownStyle()
                }
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
                    Task {
                        completeToDo()
                    }
                } label: {
                    if todo.isCompleted {
                        Label("Uncomplete", systemImage: "minus")
                            .labelStyle(.iconOnly)
                    } else {
                        Label("Complete", systemImage: "checkmark")
                            .labelStyle(.iconOnly)
                    }
                }.tint(.accentColor)
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

                Button(role: .destructive) {
                    Task {
                        archiveTodo()
                    }
                } label: {
                    Label("Archive", systemImage: "archivebox.fill")
                        .labelStyle(.iconOnly)
                }.tint(.teal)

                Button {
                    onEdit()
                } label: {
                    Label("Edit", systemImage: "pencil")
                        .labelStyle(.iconOnly)
                }.tint(Color.accentColor)
            }
            .contextMenu {
                Button {
                    Task {
                        completeToDo()
                    }
                } label: {
                    if todo.isCompleted {
                        Label("Uncomplete", systemImage: "minus")
                    } else {
                        Label("Complete", systemImage: "checkmark")
                    }
                }

                Button {
                    onEdit()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }

                Button {
                    Task {
                        archiveTodo()
                    }
                } label: {
                    Label("Archive", systemImage: "archivebox.fill")
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
            }
            .frame(maxWidth: 300, alignment: .leading)
            
            CustomLabel("\(todo.formattedDueDate)", systemImage: "calendar")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Actions
    
    private func completeToDo() {
        /// Se a to-dos não estiver completada
        if !todo.isCompleted {
            /// completa a tarefa.
            withAnimation {
                todo.isCompleted = true
                todo.completedAt = .now
            }

            /// remove as notificações agendadas
            NotificationsManager.shared.removePendingNotifications(withIdentifiers: todo.identifiers)
        } else {
            /// descompleta a tarefa.
            withAnimation {
                todo.isCompleted = false
                todo.completedAt = nil
            }

            /// Agenda as notificações novamente, sempre respeitando as preferências do usuário.
            if settings.scheduleNotifications {
                todo.scheduleNotification()
            }
        }

        WidgetCenter.shared.reloadAllTimelines()
    }

    private func archiveTodo() {
        NotificationsManager.shared.removePendingNotifications(withIdentifiers: todo.identifiers)

        withAnimation {
            todo.isArchived = true
        }

        WidgetCenter.shared.reloadAllTimelines()
    }

    private func deleteToDo() {
        NotificationsManager.shared.removePendingNotifications(withIdentifiers: todo.identifiers)

        withAnimation {
            todo.isToDoDeleted = true
            todo.deletedAt = .now
        }

        WidgetCenter.shared.reloadAllTimelines()
    }
}
