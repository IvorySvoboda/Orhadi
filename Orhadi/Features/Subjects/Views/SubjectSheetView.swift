//
//  SubjectSheetView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 20/04/25.
//

import SwiftData
import SwiftUI
import WidgetKit

struct SubjectSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ViewModel

    // MARK: - Views

    var body: some View {
        NavigationStack {
            Form {
                if !viewModel.subject.isRecess {
                    Section {
                        TextField("Name (ex: English)", text: $viewModel.draftSubject.name)
                            .autocorrectionDisabled()

                        TextField("Place (ex: Room 101)", text: $viewModel.draftSubject.place)
                            .autocorrectionDisabled()
                    }

                    Section {
                        SubjectTeacherPickerView(teacher: $viewModel.draftSubject.teacher)
                    }
                }

                Section {
                    Picker("Weekday", selection: Binding(
                        get: { Calendar.current.component(.weekday, from: viewModel.draftSubject.schedule) },
                        set: { newWeekday in
                            if let newDate = Calendar.current.nextDate(
                                after: viewModel.draftSubject.schedule,
                                matching: DateComponents(weekday: newWeekday),
                                matchingPolicy: .nextTimePreservingSmallerComponents
                            ) {
                                viewModel.draftSubject.schedule = newDate
                            }
                        })
                    ) {
                        ForEach(Array(Calendar.current.weekdaySymbols.enumerated()), id: \.offset) { index, name in
                            Text(name.capitalized).tag(index + 1)
                        }
                    }.pickerStyle(.navigationLink)

                    DatePicker("Start", selection: $viewModel.draftSubject.startTime, displayedComponents: [.hourAndMinute])

                    DatePicker("End", selection: $viewModel.draftSubject.endTime, displayedComponents: [.hourAndMinute])
                } header: {
                    Text("Schedule")
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
                        viewModel.trySave {
                            dismiss()
                        }
                    }.disabled(viewModel.draftSubject.name.isEmpty && !viewModel.draftSubject.isRecess)
                }
            }
            .alert("Schedule Conflict", isPresented: $viewModel.showConflictAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("The selected time range is invalid or overlaps with another schedule. Please adjust it before saving.")
            }
        }
    }

    // MARK: - INIT

    init(subject: Subject, isNew: Bool = false, context: ModelContext) {
        _viewModel = State(initialValue: ViewModel(subject: subject, isNew: isNew, context: context))
    }
}
