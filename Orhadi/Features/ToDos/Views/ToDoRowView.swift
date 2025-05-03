//
//  ToDoRowView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 01/05/25.
//

import SwiftUI
import MarkdownUI

struct ToDoRowView: View {
    @Environment(\.modelContext) private var context
    @Environment(Settings.self) private var settings
    @Environment(UserProfile.self) private var user
    @Environment(GameManager.self) private var game

    @State private var showDeleteConfirmation: Bool = false
    @State private var isExpanded: Bool = false

    let todo: ToDo
    let onEdit: () -> Void

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            if !todo.info.isEmpty {
                Markdown(todo.info)
                    .markdownBlockStyle(\.heading1) { configuration in
                        VStack(alignment: .leading, spacing: 0) {
                            configuration.label
                                .relativePadding(.bottom, length: .em(0.1))
                                .markdownMargin(bottom: .em(0.5))
                                .markdownTextStyle {
                                    FontWeight(.semibold)
                                    FontSize(.em(1.5))
                                }
                            Divider()
                        }
                    }
                    .markdownBlockStyle(\.heading2) { configuration in
                        configuration.label
                            .relativePadding(.bottom, length: .em(0.1))
                            .markdownMargin(bottom: .em(0.5))
                            .markdownTextStyle {
                                FontWeight(.semibold)
                                FontSize(.em(1.3))
                            }
                    }
                    .markdownBlockStyle(\.heading3) { configuration in
                        configuration.label
                            .relativePadding(.bottom, length: .em(0.1))
                            .markdownMargin(bottom: .em(0.5))
                            .markdownTextStyle {
                                FontWeight(.semibold)
                                FontSize(.em(1.1))
                            }
                    }
                    .markdownTextStyle(\.code) {
                        FontFamilyVariant(.normal)
                        ForegroundColor(Color.accentColor)
                        BackgroundColor(Color.accentColor.opacity(0.25))
                    }
                    .markdownBlockStyle(\.blockquote) { configuration in
                        configuration.label
                            .padding(5)
                            .markdownTextStyle {
                                BackgroundColor(nil)
                            }
                            .overlay(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.accentColor)
                                    .frame(width: 4)
                            }
                            .background(Color.accentColor.opacity(0.25))
                    }
            } else {
                Text("Não informado.").opacity(0.5)
            }
        } label: {
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

                    Text(todo.title.nilIfEmpty() ?? String(localized: "Não Informado"))
                        .font(.headline)
                        .lineLimit(1)
                        .foregroundStyle(todo.isCompleted ? Color.secondary : Color.font)
                }
                .frame(maxWidth: 300, alignment: .leading)

                CustomLabel("\(todo.formattedDueDate)", systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .swipeActions(edge: .leading) {
                Button(role: .destructive) {
                    completeToDo()
                } label: {
                    if todo.isCompleted {
                        Label("Descompletar", systemImage: "minus")
                            .labelStyle(.iconOnly)
                    } else {
                        Label("Completar", systemImage: "checkmark")
                            .labelStyle(.iconOnly)
                    }
                }.tint(.accentColor)
            }
            .swipeActions(edge: .trailing) {
                if settings.todosDeleteConfirmation {
                    Button {
                        showDeleteConfirmation.toggle()
                    } label: {
                        Label("Excluir", systemImage: "trash.fill")
                            .labelStyle(.iconOnly)
                    }.tint(.red)
                } else {
                    Button(role: .destructive) {
                        deleteToDo()
                    } label: {
                        Label("Excluir", systemImage: "trash.fill")
                    }
                }

                Button {
                    onEdit()
                } label: {
                    Label("Editar", systemImage: "pencil")
                        .labelStyle(.iconOnly)
                }.tint(Color.accentColor)
            }
            .alert("Excluir tarefa?", isPresented: $showDeleteConfirmation) {
                Button("Cancelar", role: .cancel) {}
                Button("Excluir", role: .destructive) {
                    deleteToDo()
                }
            }
        }
        .listRowBackground(Color.orhadiBG)
    }

    private func completeToDo() {
        let todoID = todo.id
        let identifiers = [
            "\(todoID)-1h",
            "\(todoID)-24h",
            "\(todoID)-due",
        ]

        /// Se a tarefas não estiver completada
        if !todo.isCompleted {
            /// completa a tarefa.
            withAnimation {
                todo.isCompleted = true
                todo.completedAt = .now
            }

            /// remove as notificações agendadas
            NotificationsManager.shared.removePendingNotifications(withIdentifiers: identifiers)

            /// aumenta as tarefas completadas do usuário e adiciona 100 de xp para ele.
            user.completedToDos += 1
            game.addXP(100, to: user)
        } else { /// se não
            /// descompleta a tarefa.
            withAnimation {
                todo.isCompleted = false
                todo.completedAt = nil
            }

            /// diminue as tarefas completadas do usuário e remove o xp adiciona ao usuário.
            user.completedToDos -= 1
            game.addXP(-100, to: user)

            /// Agenda as notificações novamente, sempre respeitando as preferências do usuário.
            if settings.scheduleNotifications {
                todo.scheduleNotification()
            }
        }
    }

    private func deleteToDo() {
        let todoID = todo.id
        let identifiers = [
            "\(todoID)-1h",
            "\(todoID)-24h",
            "\(todoID)-due",
        ]

        NotificationsManager.shared.removePendingNotifications(withIdentifiers: identifiers)

        withAnimation {
            todo.isDeleted = true
            context.delete(todo)
        }
    }
}
