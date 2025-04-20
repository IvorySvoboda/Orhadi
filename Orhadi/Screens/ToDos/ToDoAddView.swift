//
//  ToDoAddView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 16/04/25.
//

import SwiftUI

struct ToDoAddView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(Settings.self) private var settings

    @State private var todo: ToDo = ToDo(title: "", info: "", dueDate: Date() + 3600)

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Minha nova tarefa", text: $todo.title)
                        .autocorrectionDisabled()

                    ZStack {
                        VStack {
                            if todo.info.isEmpty {
                                Text("Fazer o dever de casa")
                                    .foregroundStyle(Color.secondary)
                                    .opacity(0.5)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, -68)

                        MarkdownTextField(text: $todo.info)
                            .frame(height: 150)
                            .padding(.leading, -5)
                    }
                } header: {
                    Text("Nova Tarefa")
                }.listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))

                Section {
                    DatePicker(
                        "Prazo",
                        selection: $todo.dueDate,
                        displayedComponents: [.hourAndMinute, .date]
                    )
                    .onChange(of: todo.dueDate) { _, newDate in
                        guard newDate > Date() else {
                            return todo.dueDate = Date() + 3600
                        }
                    }
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
                        dismiss()
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }
                    .disabled(todo.dueDate <= Date())
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
        if settings.scheduleNotifications {
            scheduleNotification(for: todo)
        }

        withAnimation(.bouncy) {
            modelContext.insert(todo)
        }
    }

    private func scheduleNotification(for todo: ToDo) {
        if let oneHourBefore = Calendar.current.date(
            byAdding: .hour, value: -1, to: todo.dueDate
        ) {
            NotificationsManager.shared.addNotification(
                identifier: "\(todo.id)-1h",
                title: todo.title,
                body: String(localized: "Falta 1 hora para a tarefa expirar."),
                date: oneHourBefore
            )
        }

        if let twentyFourHoursBefore = Calendar.current.date(
            byAdding: .hour, value: -24, to: todo.dueDate
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
            date: todo.dueDate
        )
    }
}
