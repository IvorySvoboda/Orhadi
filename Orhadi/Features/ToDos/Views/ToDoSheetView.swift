//
//  ToDoSheetView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 16/04/25.
//

import SwiftUI
import SwiftData
import WidgetKit

struct ToDoSheetView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(Settings.self) private var settings

    @State private var viewModel: ViewModel

    init(todo: ToDo, isNew: Bool, context: ModelContext) {
        _viewModel = State(initialValue: ViewModel(todo: todo, isNew: isNew, context: context))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Work of …", text: $viewModel.draftToDo.title)
                        .autocorrectionDisabled()

                    if #available(iOS 26, *) {
                        ToDoTextEditor(text: $viewModel.draftToDo.info)
                    } else {
                        ZStack {
                            VStack {
                                if viewModel.draftToDo.info.characters.isEmpty {
                                    Text("Do …")
                                        .foregroundStyle(Color.secondary)
                                        .opacity(0.5)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .padding(.top)
                            .padding(.leading, 5)

                            MarkdownTextField(text: Binding(
                                get: { String("\(viewModel.draftToDo.info.characters)") },
                                set: { viewModel.draftToDo.info = AttributedString("\($0)") }
                            ))
                            .frame(height: 200)
                        }
                    }
                }

                Section {
                    PriorityPickerView(priority: $viewModel.draftToDo.priority)
                }

                Section {
                    DisclosureGroup {
                        DatePicker(
                            "Date",
                            selection: $viewModel.draftToDo.dueDate,
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
                                Text(viewModel.draftToDo.dueDate.relativeFormatted())
                                    .font(.caption)
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                    }
                    .disclosureGroupStyle(OrhadiDisclosureGroupStyle(addPadding: false))

                    DisclosureGroup(isExpanded: Binding(
                        get: { viewModel.isHourPickerExpanded },
                        set: { newValue in
                            if viewModel.draftToDo.withHour {
                                viewModel.isHourPickerExpanded = newValue
                            }
                        }
                    )) {
                        DatePicker(
                            "Time",
                            selection: $viewModel.draftToDo.dueDate,
                            displayedComponents: [.hourAndMinute]
                        )
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                    } label: {
                        Toggle(isOn: $viewModel.draftToDo.withHour) {
                            HStack {
                                Image(systemName: "clock")
                                    .resizable()
                                    .frame(width: 23, height: 23)
                                    .foregroundStyle(Color.accentColor)
                                    .padding(.trailing, 10)
                                    .padding(.leading, 2)
                                VStack(alignment: .leading) {
                                    Text("Time")
                                    if viewModel.draftToDo.withHour {
                                        Text("\(viewModel.draftToDo.dueDate.formatToHour())")
                                            .font(.caption)
                                            .foregroundStyle(Color.accentColor)
                                    }
                                }
                            }
                        }
                    }
                    .onChange(of: viewModel.draftToDo.withHour) { _, newValue in
                        if !newValue {
                            withAnimation {
                                viewModel.isHourPickerExpanded = false
                            }
                        }
                    }
                    .disclosureGroupStyle(OrhadiDisclosureGroupStyle(addPadding: false))
                }
            }
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark", role: .cancel) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", systemImage: "checkmark") {
                        viewModel.trySave(scheduleNotifications: settings.scheduleNotifications) {
                            dismiss()
                        }
                    }.disabled(viewModel.draftToDo.title.isEmpty)
                }
            }
        }
    }
}
