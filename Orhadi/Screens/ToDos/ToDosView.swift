//
//  TasksView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 26/03/25.
//

import SwiftData
import SwiftUI
import MarkdownUI

struct ToDosView: View {
    @Environment(OrhadiTheme.self) private var theme
    @Environment(Settings.self) private var settings

    @Query(sort: [.init(\ToDo.dueDate, order: .forward)], animation: .bouncy)
    private var todos: [ToDo]

    @State private var todoToAdd: ToDo?

    var body: some View {
        NavigationStack {
            List {
                if !todos.filter({ $0.dueDate > Date() && !$0.isCompleted }).isEmpty {
                    Section {
                        ForEach(todos.filter { $0.dueDate > Date() && !$0.isCompleted })
                        { todo in
                            ToDoRow(todo: todo)
                        }
                    } header: {
                        SectionHeader(text: String(localized: "A Fazer"))
                    }.listRowBackground(theme.bgColor())
                }

                if !todos.filter({$0.dueDate < Date() || $0.isCompleted}).isEmpty {
                    Section {
                        ForEach(
                            todos.sorted(by: { $0.dueDate > $1.dueDate }).filter {
                                $0.dueDate < Date() || $0.isCompleted
                            }
                        ) { todo in
                            ToDoRow(todo: todo)
                        }
                    } header: {
                        SectionHeader(text: String(localized: "Completados ou Vencidos"))
                    }.listRowBackground(theme.bgColor())
                }
            }
            .modifier(DefaultPlainList())
            .navigationTitle("Tarefas")
            .overlay {
                overlay
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        todoToAdd = ToDo()
                    } label: {
                        Image(systemName: "plus.circle.fill").font(.title2)
                    }
                }
            }
            .sheet(item: $todoToAdd) { todo in
                ToDoSheetView(todo: todo, isNew: true)
                    .interactiveDismissDisabled()
            }
        }
    }

    private var overlay: some View {
        Group {
            if todos.isEmpty {
                ContentUnavailableView {
                    Label("Sem Tarefas", systemImage: "list.bullet.clipboard")
                } description: {
                    Text("Adicione novas tarefas para começar a se organizar.")
                } actions: {
                    Button("Adicionar Tarefa") {
                        todoToAdd = ToDo()
                    }
                    .buttonStyle(.borderedProminent)
                    .foregroundStyle(theme.bgColor())
                }
            }
        }
    }
}

#Preview("ToDoView") {
    ToDosView()
        .modelContainer(SampleData.shared.container)
        .environment(Settings())
}

struct ToDoRow: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Settings.self) private var settings
    @Environment(UserProfile.self) private var user
    @Environment(GameManager.self) private var game

    @State private var showConfirmation: Bool = false

    var todo: ToDo

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

            if todo.dueDate < Date() && !todo.isCompleted {
                Image(systemName: "xmark")
                    .foregroundStyle(.red)
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
                completeSwipeAction
            }
            .swipeActions(edge: .trailing) {
                deleteSwipeAction
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

    private var completeSwipeAction: some View {
        Group {
            if !todo.isCompleted && todo.dueDate > Date() {
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

    // MARK: - Functions

    private func completeToDo() {
        let todoID = todo.id
        let identifiers = [
            "\(todoID)-1h",
            "\(todoID)-24h",
            "\(todoID)-due",
        ]

        NotificationsManager.shared.removePendingNotifications(withIdentifiers: identifiers)

        user.completedToDos += 1
        game.addXP(100, to: user)

        withAnimation(.bouncy) {
            todo.isCompleted = true
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
