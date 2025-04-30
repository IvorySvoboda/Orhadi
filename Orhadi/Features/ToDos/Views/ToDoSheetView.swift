//
//  ToDoSheetView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 16/04/25.
//

import SwiftUI

struct ToDoSheetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(Settings.self) private var settings

    @State private var isHourPickerExpanded = false

    @Bindable var todo: ToDo

    var isNew: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Trabalho de...", text: $todo.title)
                        .autocorrectionDisabled()

                    ZStack {
                        VStack {
                            if todo.info.isEmpty {
                                Text("Fazer ... ")
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
                }.listRowBackground(Color.orhadiSecondaryBG)

                Section {
                    ToDoPriorityPickerView(todo: todo)
                }.listRowBackground(Color.orhadiSecondaryBG)

                Section {
                    DisclosureGroup {
                        DatePicker(
                            "Data",
                            selection: $todo.dueDate,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.graphical)
                    } label: {
                        HStack {
                            Image(systemName: "calendar")
                                .resizable()
                                .frame(width: 23, height: 23)
                                .foregroundStyle(Color.accentColor)
                                .padding(.trailing, 10)
                                .padding(.leading, 2)
                            VStack(alignment: .leading) {
                                Text("Data")
                                Text(todo.dueDate.relativeFormated())
                                    .font(.caption)
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                    }
                    .disclosureGroupStyle(OrhadiDisclosureGroupStyle(addPadding: false))

                    DisclosureGroup(isExpanded: Binding(
                        get: { isHourPickerExpanded },
                        set: { newValue in
                            if todo.withHour {
                                isHourPickerExpanded = newValue
                            }
                        }
                    )) {
                        DatePicker(
                            "Hora",
                            selection: $todo.dueDate,
                            displayedComponents: [.hourAndMinute]
                        )
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                    } label: {
                        Toggle(isOn: $todo.withHour) {
                            HStack {
                                Image(systemName: "clock")
                                    .resizable()
                                    .frame(width: 23, height: 23)
                                    .foregroundStyle(Color.accentColor)
                                    .padding(.trailing, 10)
                                    .padding(.leading, 2)
                                VStack(alignment: .leading) {
                                    Text("Hora")
                                    if todo.withHour {
                                        Text("\(todo.dueDate.formatToHour())")
                                            .font(.caption)
                                            .foregroundStyle(Color.accentColor)
                                    }
                                }
                            }
                        }
                    }
                    .onChange(of: todo.withHour) { _, newValue in
                        if !newValue {
                            withAnimation {
                                isHourPickerExpanded = false
                            }
                        }
                    }
                    .disclosureGroupStyle(OrhadiDisclosureGroupStyle(addPadding: false))
                }
                .listRowBackground(Color.orhadiSecondaryBG)
            }
            .orhadiListStyle()
            .navigationTitle("\(isNew ? "Nova" : "Editar") Tarefa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isNew {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancelar", role: .cancel) {
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        if isNew {
                            addItem()
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        } else {
                            /// Se não for uma tarefa nova, atualiza as notificações agendadas.
                            let todoID = todo.id
                            let identifiers = [
                                "\(todoID)-1h",
                                "\(todoID)-24h",
                                "\(todoID)-due",
                            ]

                            NotificationsManager.shared.removePendingNotifications(withIdentifiers: identifiers)

                            if !todo.withHour {
                                todo.dueDate = Calendar.current.startOfDay(for: todo.dueDate)
                            }

                            /// Sempre respeitando as preferências do usuário.
                            if settings.scheduleNotifications {
                                todo.scheduleNotification()
                            }

                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        }
                        dismiss()
                    }.disabled(todo.title.isEmpty)
                }
            }
        }
    }

    private func addItem() {
        if settings.scheduleNotifications {
            todo.scheduleNotification()
        }

        if !todo.withHour {
            todo.dueDate = Calendar.current.startOfDay(for: todo.dueDate)
        }

        withAnimation {
            modelContext.insert(todo)
        }
    }
}
