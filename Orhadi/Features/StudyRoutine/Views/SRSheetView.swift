//
//  SRSheetView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 21/04/25.
//

import SwiftUI
import SwiftData

struct SRSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name (ex: English)", text: $viewModel.draftStudy.name)
                        .autocorrectionDisabled()
                }

                Section {
                    Picker("Weekday", selection: Binding(
                        get: { Calendar.current.component(.weekday, from: viewModel.draftStudy.studyDay) },
                        set: { newWeekday in
                            if let newDate = Calendar.current.nextDate(
                                after: viewModel.draftStudy.studyDay,
                                matching: DateComponents(weekday: newWeekday),
                                matchingPolicy: .nextTimePreservingSmallerComponents
                            ) {
                                viewModel.draftStudy.studyDay = newDate
                            }
                        })
                    ) {
                        ForEach(Array(Calendar.current.weekdaySymbols.enumerated()), id: \.offset) { index, name in
                            Text(name.capitalized).tag(index + 1)
                        }
                    }.pickerStyle(.navigationLink)

                    DatePicker(
                        "Study Duration",
                        selection: $viewModel.draftStudy.studyTime,
                        displayedComponents: [.hourAndMinute]
                    )
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
                        try? viewModel.trySave {
                            dismiss()
                        }
                    }.disabled(viewModel.draftStudy.name.isEmpty)
                }
            }
        }
    }

    // MARK: - INIT

    init(study: SRStudy, isNew: Bool) {
        _viewModel = State(initialValue: ViewModel(study: study, isNew: isNew, dataManager: .shared))
    }
}
