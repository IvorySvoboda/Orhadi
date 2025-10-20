//
//  ToDoSheetView.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 16/04/25.
//

import SwiftUI
import WidgetKit

struct ToDoSheetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(Settings.self) private var settings

    @State private var isHourPickerExpanded = false
    @State private var title: String
    @State private var info: AttributedString
    @State private var priority: Priority
    @State private var dueDate: Date
    @State private var withHour: Bool

    @Bindable var todo: ToDo
    var isNew: Bool

    private var navigationTitle: LocalizedStringKey {
        if isNew {
            return "New To-Do"
        } else {
            return "Edit To-Do"
        }
    }

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
                    TextField("Work of …", text: $title)
                        .autocorrectionDisabled()

                    if #available(iOS 26, *) {
                        ToDoTextEditor(text: $info)
                    } else {
                        ZStack {
                            VStack {
                                if info.characters.isEmpty {
                                    Text("Do …")
                                        .foregroundStyle(Color.secondary)
                                        .opacity(0.5)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .padding(.top)
                            .padding(.leading, 5)

                            MarkdownTextField(text: Binding(
                                get: { String("\(info.characters)") },
                                set: { info = AttributedString("\($0)") }
                            ))
                            .frame(height: 200)
                        }
                    }
                }

                Section {
                    PriorityPickerView(priority: $priority)
                }

                Section {
                    DisclosureGroup {
                        DatePicker(
                            "Date",
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
                                Text("Date")
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
                            "Time",
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
                                    Text("Time")
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
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel, action: { dismiss() }) {
                        Label("Cancel", systemImage: "xmark")
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(action: trySave) {
                        Label("Save", systemImage: "checkmark")
                    }.disabled(title.isEmpty)
                }
            }
        }
    }

    // MARK: - Actions

    private func trySave() {
        if isNew {
            insertNewToDo()
        } else {
            applyToDoChanges()
        }

        WidgetCenter.shared.reloadAllTimelines()
        dismiss()
    }

    private func insertNewToDo() {
        let newTodo = ToDo(
            title: title.trimmingCharacters(in: .whitespaces),
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

        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    private func applyToDoChanges() {
        todo.title = title.trimmingCharacters(in: .whitespaces)
        todo.info = info
        todo.dueDate = dueDate
        todo.priority = priority
        todo.withHour = withHour

        /// Se não for uma tarefa nova, atualiza as notificações agendadas.
        NotificationsManager.shared.removePendingNotifications(withIdentifiers: todo.identifiers)

        if !todo.withHour {
            todo.dueDate = Calendar.current.startOfDay(for: todo.dueDate)
        }

        /// Sempre respeitando as preferências do usuário.
        if settings.scheduleNotifications {
            todo.scheduleNotification()
        }

        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
}
