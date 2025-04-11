//
//  TasksView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 26/03/25.
//

import SwiftData
import SwiftUI

struct ToDosView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(Settings.self) private var settings

    @Query(sort: [.init(\ToDo.dueDate, order: .forward)], animation: .bouncy)
    private var todos: [ToDo]

    @State private var isAdding: Bool = false
    @State private var isEditing: Bool = false

    var body: some View {
        NavigationStack {
            List {
                if !todos.filter({ $0.dueDate > Date() && !$0.isCompleted }).isEmpty {
                    Section {
                        ForEach(todos.filter { $0.dueDate > Date() && !$0.isCompleted })
                        { todo in
                            ToDosListCell(todo: todo, isEditing: isEditing)
                        }
                    } header: {
                        SectionHeader(text: String(localized: "A Fazer"))
                    }
                }

                if !todos.filter({$0.dueDate < Date() || $0.isCompleted}).isEmpty {
                    Section {
                        ForEach(
                            todos.sorted(by: { $0.dueDate > $1.dueDate }).filter {
                                $0.dueDate < Date() || $0.isCompleted
                            }
                        ) { todo in
                            ToDosListCell(todo: todo, isEditing: isEditing)
                        }
                    } header: {
                        SectionHeader(text: String(localized: "Completados ou Vencidos"))
                    }
                }
            }
            .listStyle(PlainListStyle())
            .background(OrhadiTheme.getBGColor(for: colorScheme))
            .navigationTitle("Tarefas")
            .toolbar {
                if !settings.editButton {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { isAdding = true }) {
                            Image(systemName: "plus.circle.fill").font(.title2)
                        }
                    }
                }
                if settings.editButton {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            if isEditing {
                                isAdding = true
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .blur(radius: isEditing ? 0 : 4)
                        }.opacity(isEditing ? 1 : 0)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            withAnimation(.bouncy) {
                                isEditing.toggle()
                            }
                        }) {
                            Text("\(isEditing ? "OK" : "Editar")")
                        }
                    }
                }
            }
            .toolbarBackground(
                OrhadiTheme.getBGColor(for: colorScheme),
                for: .navigationBar)
        }
        .sheet(
            isPresented: $isAdding,
            onDismiss: { isAdding = false },
            content: {
                ToDoAddView().interactiveDismissDisabled()
            })
    }
}

struct ToDosListCell: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Settings.self) private var settings

    @State private var showConfirmation: Bool = false

    var todo: ToDo
    var isEditing: Bool

    var body: some View {
        DisclosureGroup(
            content: {
                if !todo.info.isEmpty {
                    Text(.init("\(todo.info)"))
                } else {
                    Text("Não informado.").opacity(0.5)
                }
            },
            label: {
                if todo.isCompleted {
                    Image(systemName: "checkmark")
                }

                if todo.dueDate < Date() && !todo.isCompleted {
                    Image(systemName: "xmark")
                }

                ZStack {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: isEditing ? 28 : 18, height: isEditing ? 28 : 18)
                        .blur(radius: isEditing ? 0 : 8)
                        .offset(x: -155)
                        .opacity(isEditing && settings.editButton
                                 && (todo.dueDate > Date() && !todo.isCompleted) ? 1 : 0)
                        .font(.title)
                        .foregroundStyle(isEditing ? Color.blue : Color.secondary)
                        .onTapGesture {
                            guard isEditing && settings.editButton else { return }
                            completeToDo(for: todo)
                        }

                    VStack(alignment: .leading) {
                        Text("\(todo.title.isEmpty ? String(localized: "Não Informado") : todo.title)")
                            .font(.headline)
                        Text(formatDueDate(todo.dueDate))
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .offset(x: (isEditing && settings.editButton) && todo.dueDate > Date() && !todo.isCompleted ? 45 : 0)

                    Image(systemName: "minus.circle.fill")
                        .resizable()
                        .frame(width: isEditing ? 28 : 18, height: isEditing ? 28 : 18)
                        .blur(radius: isEditing ? 0 : 8)
                        .offset(x: todo.dueDate < Date() || todo.isCompleted ? 160 : 170)
                        .opacity(isEditing && settings.editButton ? 1 : 0)
                        .font(.title)
                        .foregroundStyle(isEditing ? Color.red : Color.secondary)
                        .onTapGesture {
                            guard settings.todosDeleteConfirmation && (isEditing && settings.editButton) else {
                                return deleteToDo(for: todo)
                            }
                            showConfirmation.toggle()
                        }
                }
                .swipeActions(edge: .leading) {
                    if !todo.isCompleted && todo.dueDate > Date()
                        && (!isEditing || !settings.editButton)
                    {
                        Button(role: .destructive, action: { completeToDo(for: todo) }) {
                            Label("Completar", systemImage: "checkmark")
                        }.tint(.blue)
                    }
                }
                .swipeActions(edge: .trailing) {
                    if settings.todosDeleteConfirmation
                        && settings.swipeActions
                        && settings.todosDeleteButton
                        && (!isEditing || !settings.editButton)
                    {
                        Button(action: {
                                showConfirmation.toggle()
                            }
                        ) {
                            Label("Excluir", systemImage: "trash.fill")
                        }.tint(.red)
                    }
                    if !settings.todosDeleteConfirmation
                        && settings.swipeActions
                        && settings.todosDeleteButton
                        && (!isEditing || !settings.editButton)
                    {
                        Button(role: .destructive, action: {
                            deleteToDo(for: todo)
                            }
                        ) {
                            Label("Excluir", systemImage: "trash.fill")
                        }.tint(.red)

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
        .listRowBackground(Color.clear)
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

struct ToDoAddView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(Settings.self) private var settings

    @State private var title: String = ""
    @State private var info: String = ""
    @State private var dueDate: Date = Date() + 3600

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Minha nova tarefa", text: $title)
                        .autocorrectionDisabled()

                    ZStack {
                        VStack {
                            if info.isEmpty {
                                Text("Fazer o dever de casa")
                                    .foregroundStyle(Color.secondary)
                                    .opacity(0.5)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, -68)

                        MarkdownTextField(text: $info)
                            .autocorrectionDisabled()
                            .frame(height: 150)
                            .padding(.leading, -5)
                    }

                    DatePicker(
                        "Prazo:",
                        selection: $dueDate,
                        displayedComponents: [.hourAndMinute, .date]
                    )
                    .onChange(of: dueDate) { _, newDate in
                        guard newDate > Date() else {
                            dueDate = Date() + 3600
                            return
                        }
                    }
                } header: {
                    Text("Nova Tarefa")
                }.listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))
            }
            .background(OrhadiTheme.getBGColor(for: colorScheme))
            .scrollContentBackground(.hidden)
            .navigationTitle("Nova Tarefa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        addItem()
                    }
                    .disabled(dueDate <= Date())
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
    }

    private func addItem() {
        let newTodo = ToDo(
            title: title,
            info: info,
            dueDate: dueDate
        )

        if settings.scheduleNotifications {
            scheduleNotification(for: newTodo)
        }

        withAnimation(.bouncy) {
            modelContext.insert(newTodo)
        }

        dismiss()
    }

    private func scheduleNotification(for todo: ToDo) {
        if let oneHourBefore = Calendar.current.date(
            byAdding: .hour, value: -1, to: dueDate
        ) {
            NotificationsManager.shared.addNotification(
                identifier: "\(todo.id)-1h",
                title: todo.title,
                body: String(localized: "Falta 1 hora para a tarefa expirar."),
                date: oneHourBefore
            )
        }

        if let twentyFourHoursBefore = Calendar.current.date(
            byAdding: .hour, value: -24, to: dueDate
        ) {
            NotificationsManager.shared.addNotification(
                identifier: "\(todo.id)-24h",
                title: todo.title,
                body: String(localized: "Falta 1 dia para a tarefa expirar."),
                date: twentyFourHoursBefore
            )
        }

        NotificationsManager.shared.addNotification(
            identifier: "\(todo.id)-due",
            title: String(localized: "A Tarefa Venceu!"),
            body: String(localized: "A Tarefa: \(todo.title) Venceu!"),
            date: dueDate
        )
    }
}

#Preview("ToDoView") {
    ToDosView()
        .modelContainer(SampleData.shared.container)
        .environment(Settings())
}
