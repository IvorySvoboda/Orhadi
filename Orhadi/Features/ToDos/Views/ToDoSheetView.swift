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
    @State private var title: String
    @State private var info: String
    @State private var priority: Priority
    @State private var dueDate: Date
    @State private var withHour: Bool

    @Bindable var todo: ToDo
    var isNew: Bool

    init(todo: ToDo, isNew: Bool) {
        self.todo = todo
        self.isNew = isNew

        _title = State(initialValue: todo.title)
        _info = State(initialValue: todo.info)
        _priority = State(initialValue: todo.priority)
        _dueDate = State(initialValue: todo.dueDate)
        _withHour = State(initialValue: todo.withHour)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Trabalho de...", text: $title)
                        .autocorrectionDisabled()

                    ZStack {
                        VStack {
                            if info.isEmpty {
                                Text("Fazer ... ")
                                    .foregroundStyle(Color.secondary)
                                    .opacity(0.5)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(.top)
                        .padding(.leading, 5)

                        MarkdownTextField(text: $info)
                            .frame(height: 200)
                    }
                }.listRowBackground(Color.orhadiSecondaryBG)

                Section {
                    PriorityPickerView(priority: $priority)
                }.listRowBackground(Color.orhadiSecondaryBG)

                Section {
                    DisclosureGroup {
                        DatePicker(
                            "Data",
                            selection: $dueDate,
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
                                Text(dueDate.relativeFormatted())
                                    .font(.caption)
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                    }
                    .disclosureGroupStyle(OrhadiDisclosureGroupStyle(addPadding: false))

                    DisclosureGroup(isExpanded: Binding(
                        get: { isHourPickerExpanded },
                        set: { newValue in
                            if withHour {
                                isHourPickerExpanded = newValue
                            }
                        }
                    )) {
                        DatePicker(
                            "Hora",
                            selection: $dueDate,
                            displayedComponents: [.hourAndMinute]
                        )
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                    } label: {
                        Toggle(isOn: $withHour) {
                            HStack {
                                Image(systemName: "clock")
                                    .resizable()
                                    .frame(width: 23, height: 23)
                                    .foregroundStyle(Color.accentColor)
                                    .padding(.trailing, 10)
                                    .padding(.leading, 2)
                                VStack(alignment: .leading) {
                                    Text("Hora")
                                    if withHour {
                                        Text("\(dueDate.formatToHour())")
                                            .font(.caption)
                                            .foregroundStyle(Color.accentColor)
                                    }
                                }
                            }
                        }
                    }
                    .onChange(of: withHour) { _, newValue in
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
                            todo.title = title
                            todo.info = info
                            todo.dueDate = dueDate
                            todo.priority = priority
                            todo.withHour = withHour

                            /// Se não for uma tarefa nova, atualiza as notificações agendadas.
                            let todoID = todo.id
                            let identifiers = [
                                "\(todoID)-1h",
                                "\(todoID)-24h",
                                "\(todoID)-due"
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
                    }.disabled(title.isEmpty)
                }
            }
        }
    }

    private func addItem() {
        let newTodo = ToDo(
            title: title,
            info: info,
            dueDate: dueDate,
            withHour: withHour,
            priority: priority
        )

        if settings.scheduleNotifications {
            newTodo.scheduleNotification()
        }

        if !newTodo.withHour {
            newTodo.dueDate = Calendar.current.startOfDay(for: newTodo.dueDate)
        }

        withAnimation {
            modelContext.insert(newTodo)
        }
    }
}
