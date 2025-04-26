//
//  ToDoRow.swift
//  Orhadi
//
//  Created by Zyvoxi . on 26/04/25.
//

import SwiftUI
import MarkdownUI

struct ToDoRow: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Settings.self) private var settings
    @Environment(UserProfile.self) private var user
    @Environment(GameManager.self) private var game

    @State private var showConfirmation: Bool = false

    var todo: ToDo
    @Binding var todoToEdit: ToDo?

    // MARK: - Views

    var body: some View {
        DisclosureGroup {
            todoInfo
        } label: {
            todoLabel
        }
        .disclosureGroupStyle(CustomDisclosureGroupStyle())
    }

    // MARK: DisclosureGroup Content

    private var todoInfo: some View {
        Group {
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
        }
    }

    private var todoLabel: some View {
        Group {
            if todo.isCompleted {
                Image(systemName: "checkmark")
                    .foregroundStyle(Color.accentColor)
            }

            if !todo.isCompleted {
                /// `dueDate` menor que a data atual, porém ao adicionar o período de tolerância fica maior que a data atual?
                /// exibe ⚠️.
                if todo.dueDate < Date() && todo.dueDate.addingTimeInterval(settings.gracePeriod) > Date() {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                }
                /// Se mesmo com com período de tolerância o `dueDate` for menor que que a data atual,
                /// exibe ❌.
                if todo.dueDate.addingTimeInterval(settings.gracePeriod) < Date() {
                    Image(systemName: "xmark")
                        .foregroundStyle(.red)
                }
            }

            VStack(alignment: .leading) {
                Text(todo.title.nilIfEmpty() ?? String(localized: "Não Informado"))
                    .font(.headline)
                    .lineLimit(1)
                    .frame(maxWidth: 200, alignment: .leading)
                CustomLabel("\(formatDueDate(todo.dueDate))", systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .swipeActions(edge: .leading) {
                completeToggleSwipeAction
            }
            .swipeActions(edge: .trailing) {
                deleteSwipeAction
                editSwipeAction
            }
            .alert("Excluir tarefa?", isPresented: $showConfirmation) {
                Button("Cancelar", role: .cancel) {}
                Button("Excluir", role: .destructive) {
                    deleteToDo()
                }
            } message: {
                Text("Essa ação é permanente e não pode ser desfeita. Tem certeza de que deseja excluir esta tarefa?")
            }
        }
    }

    // MARK: Swipe Actions

    private var completeToggleSwipeAction: some View {
        Group {
            /// Permite alterar o estado de completo/incompleto apenas se
            /// o `dueDate`, considerando o período de tolerância, for maior que a data atual.
            if todo.dueDate.addingTimeInterval(settings.gracePeriod) > Date() {
                Button(role: .destructive, action: { completeToDo() }) {
                    Label("Completar", systemImage: "checkmark")
                }.tint(.accentColor)
            }
        }
    }

    private var deleteSwipeAction: some View {
        Group {
            if settings.todosDeleteConfirmation {
                Button(action: {
                    showConfirmation.toggle()
                }) {
                    Label("Excluir", systemImage: "trash.fill")
                }
                .tint(.red)
            } else {
                Button(role: .destructive, action: {
                    deleteToDo()
                }) {
                    Label("Excluir", systemImage: "trash.fill")
                }
            }
        }
    }

    private var editSwipeAction: some View {
        Button {
            todoToEdit = todo
        } label: {
            Label("Editar", systemImage: "pencil")
                .labelStyle(.iconOnly)
        }.tint(Color.accentColor)
    }

    // MARK: - Functions

    private func completeToDo() {
        /// Se a tarefas não estiver completada
        if !todo.isCompleted {
            let todoID = todo.id
            let identifiers = [
                "\(todoID)-1h",
                "\(todoID)-24h",
                "\(todoID)-due",
            ]

            /// remove as notificações agendadas
            NotificationsManager.shared.removePendingNotifications(withIdentifiers: identifiers)

            /// aumenta as tarefas completadas do usuário e adiciona 100 de xp para ele.
            user.completedToDos += 1
            game.addXP(100, to: user)

            /// completa a tarefa.
            withAnimation(.bouncy) {
                todo.isCompleted = true
            }
        } else { /// se não
            /// diminue as tarefas completadas do usuário e remove o xp adiciona ao usuário.
            user.completedToDos -= 1
            game.addXP(-100, to: user)

            /// Agenda as notificações novamente, sempre respeitando as preferências do usuário.
            if settings.scheduleNotifications {
                todo.scheduleNotification()
            }

            /// descompleta a tarefa.
            withAnimation(.bouncy) {
                todo.isCompleted = false
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

        withAnimation(.bouncy) {
            modelContext.delete(todo)
        }
    }
}
