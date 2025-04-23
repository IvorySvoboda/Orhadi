//
//  ToDoSheetView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 16/04/25.
//

import SwiftUI

struct ToDoSheetView: View {
    @Environment(OrhadiTheme.self) private var theme
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(Settings.self) private var settings

    @Bindable var todo: ToDo
    var isNew: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Título")
                            .frame(width: 50, alignment: .leading)
                        TextField("Trabalho de...", text: $todo.title)
                            .autocorrectionDisabled()
                    }

                    ZStack {
                        VStack {
                            if todo.info.isEmpty {
                                Text("Fazer o trabalho em grupo...")
                                    .foregroundStyle(Color.secondary)
                                    .opacity(0.5)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(.top)
                        .padding(.leading, 5)

                        MarkdownTextField(text: $todo.info)
                            .frame(height: 200)
                    }
                }.listRowBackground(theme.secondaryBGColor())

                Section {
                    DatePicker(
                        "Prazo",
                        selection: $todo.dueDate,
                        displayedComponents: [.hourAndMinute, .date]
                    )
                    .disabled(todo.dueDate.addingTimeInterval(settings.gracePeriod) < Date() && !isNew)
                    .onChange(of: todo.dueDate) { _, newDate in
                        guard newDate > Date() else {
                            return todo.dueDate = Date().addingTimeInterval(3600)
                        }
                    }
                }.listRowBackground(theme.secondaryBGColor())
            }
            .modifier(DefaultList())
            .navigationTitle("\(isNew ? "Nova" : "Editar") Tarefa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        if isNew {
                            addItem()
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        } else {
                            let todoID = todo.id
                            let identifiers = [
                                "\(todoID)-1h",
                                "\(todoID)-24h",
                                "\(todoID)-due",
                            ]

                            NotificationsManager.shared.removePendingNotifications(withIdentifiers: identifiers)

                            todo.scheduleNotification()

                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        }
                        dismiss()
                    }.disabled(todo.title.isEmpty)
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
            todo.scheduleNotification()
        }

        withAnimation(.bouncy) {
            modelContext.insert(todo)
        }
    }
}
