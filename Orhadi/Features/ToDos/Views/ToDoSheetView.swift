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
    @Environment(\.dismiss) private var dismiss
    @State private var vm: ViewModel

    // MARK: - INIT

    init(todo: ToDo, isNew: Bool) {
        _vm = State(initialValue: ViewModel(todo: todo, isNew: isNew, dataManager: .shared))
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                todoInfoSection
                todoPrioritySection
                todoDueSection
            }
            .navigationTitle(vm.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarComponents }
        }
    }

    // MARK: Form Components

    private var todoInfoSection: some View {
        Section {
            TextField("Work of …", text: $vm.draftToDo.title)
                .autocorrectionDisabled()

                ZStack {
                    if vm.draftToDo.info.characters.isEmpty {
                        Text("Do …")
                            .foregroundStyle(Color.secondary)
                            .opacity(0.5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .padding(.top, 10)
                            .padding(.leading, 5)
                    }

                    if #available(iOS 26, *) {
                        ToDoTextEditor(text: $vm.draftToDo.info)
                    } else {
                        TextEditor(text: Binding(
                            get: { String("\(vm.draftToDo.info.characters)") },
                            set: { vm.draftToDo.info = AttributedString("\($0)") }
                        )).frame(height: 300)
                    }
            }
        }
    }

    private var todoPrioritySection: some View {
        Section {
            PriorityPicker(priority: $vm.draftToDo.priority)
        } header: {
            Text("Priority")
        }
    }

    private var todoDueSection: some View {
        Section {
            DisclosureGroup {
                DatePicker(
                    "Date",
                    selection: $vm.draftToDo.dueDate,
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
                        Text(vm.draftToDo.dueDate.relativeFormatted())
                            .font(.caption)
                            .foregroundStyle(Color.accentColor)
                    }
                }
            }.disclosureGroupStyle(OrhadiDisclosureGroupStyle(addPadding: false))

            DisclosureGroup(isExpanded: vm.isTimePickerExpanded) {
                DatePicker(
                    "Time",
                    selection: $vm.draftToDo.dueDate,
                    displayedComponents: [.hourAndMinute]
                )
                .labelsHidden()
                .datePickerStyle(.wheel)
            } label: {
                Toggle(isOn: $vm.draftToDo.withHour) {
                    HStack {
                        Image(systemName: "clock")
                            .resizable()
                            .frame(width: 23, height: 23)
                            .foregroundStyle(Color.accentColor)
                            .padding(.trailing, 10)
                            .padding(.leading, 2)
                        VStack(alignment: .leading) {
                            Text("Time")
                            if vm.draftToDo.withHour {
                                Text("\(vm.draftToDo.dueDate.formatToHour())")
                                    .font(.caption)
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                    }
                }
            }
            .disclosureGroupStyle(OrhadiDisclosureGroupStyle(addPadding: false))
        } header: {
            Text("Due")
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarComponents: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel", systemImage: "xmark", role: .cancel) {
                dismiss()
            }
        }

        ToolbarItem(placement: .confirmationAction) {
            Button("Save", systemImage: "checkmark") {
                try? vm.trySave {
                    dismiss()
                }
            }.disabled(vm.draftToDo.title.isEmpty)
        }
    }
}
