//
//  ToDosListCell.swift
//  Orhadi
//
//  Created by Zyvoxi . on 16/04/25.
//

import MarkdownUI
import SwiftUI

struct ToDosListCell: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Settings.self) private var settings

    @State private var showConfirmation: Bool = false

    var todo: ToDo

    var body: some View {
        DisclosureGroup(
            content: {
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
            },
            label: {
                if todo.isCompleted {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.accentColor)
                }

                if todo.dueDate < Date() && !todo.isCompleted {
                    Image(systemName: "xmark")
                        .foregroundStyle(Color.accentColor)
                }

                VStack(alignment: .leading) {
                    Text("\(todo.title.isEmpty ? String(localized: "Não Informado") : todo.title)")
                        .font(.headline)
                    HStack {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(formatDueDate(todo.dueDate))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .swipeActions(edge: .leading) {
                    if !todo.isCompleted && todo.dueDate > Date() {
                        Button(role: .destructive, action: { completeToDo(for: todo) }) {
                            Label("Completar", systemImage: "checkmark")
                        }.tint(.accentColor)
                    }
                }
                .swipeActions(edge: .trailing) {
                    if settings.todosDeleteConfirmation {
                        Button(action: {
                            showConfirmation.toggle()
                        }) {
                            Label("Excluir", systemImage: "trash.fill")
                        }
                        .tint(.red)
                    }
                    if !settings.todosDeleteConfirmation {
                        Button(role: .destructive, action: {
                            deleteToDo(for: todo)
                        }) {
                            Label("Excluir", systemImage: "trash.fill")
                        }
                    }
                }
                .alert("Excluir tarefa?", isPresented: $showConfirmation) {
                    Button("Cancelar", role: .cancel) {}
                    Button("Excluir", role: .destructive) {
                        deleteToDo(for: todo)
                    }
                } message: {
                    Text(
                        "Essa ação é permanente e não pode ser desfeita. Tem certeza de que deseja excluir esta tarefa?"
                    )
                }
            }
        )
        .disclosureGroupStyle(CustomDisclosureGroupStyle())
    }

    private func completeToDo(for todo: ToDo) {
        let todoID = todo.id
        let identifiers = [
            "\(todoID)-1h",
            "\(todoID)-24h",
            "\(todoID)-due",
        ]

        NotificationsManager.shared.removePendingNotifications(withIdentifiers: identifiers)

        withAnimation(.bouncy) {
            todo.isCompleted = true
        }
    }

    private func deleteToDo(for todo: ToDo) {
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
