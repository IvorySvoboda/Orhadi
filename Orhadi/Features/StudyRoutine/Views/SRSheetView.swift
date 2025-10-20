//
//  SRSheetView.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 21/04/25.
//

import SwiftUI

struct SRSheetView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var studyDay: Date
    @State private var studyTime: Date

    @Bindable var study: SRStudy
    var isNew: Bool
    
    private var navigationTitle: LocalizedStringKey {
        if isNew {
            return "New Study"
        } else {
            return "Edit Study"
        }
    }

    init(study: SRStudy, isNew: Bool) {
        self.study = study
        self.isNew = isNew

        _name = State(initialValue: study.name)
        _studyDay = State(initialValue: study.studyDay)
        _studyTime = State(initialValue: study.studyTime)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name (ex: English)", text: $name)
                        .autocorrectionDisabled()
                }

                Section {
                    Picker("Weekday", selection: Binding(
                        get: { Calendar.current.component(.weekday, from: studyDay) },
                        set: { newWeekday in
                            if let newDate = Calendar.current.nextDate(
                                after: studyDay,
                                matching: DateComponents(weekday: newWeekday),
                                matchingPolicy: .nextTimePreservingSmallerComponents
                            ) {
                                studyDay = newDate
                            }
                        })
                    ) {
                        ForEach(Array(Calendar.current.weekdaySymbols.enumerated()), id: \.offset) { index, name in
                            Text(name.capitalized).tag(index + 1)
                        }
                    }.pickerStyle(.navigationLink)

                    DatePicker(
                        "Study Duration",
                        selection: $studyTime,
                        displayedComponents: [.hourAndMinute]
                    )
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
                    }.disabled(name.isEmpty)
                }
            }
        }
    }

    // MARK: - Actions

    private func trySave() {
        if isNew {
            insertNewStudy()
        } else {
            applyStudyChanges()
        }

        dismiss()
    }

    private func insertNewStudy() {
        withAnimation {
            context.insert(SRStudy(
                name: name.trimmingCharacters(in: .whitespaces),
                studyDay: studyDay,
                studyTime: studyTime
            ))
        }

        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    private func applyStudyChanges() {
        study.name = name.trimmingCharacters(in: .whitespaces)
        study.studyDay = studyDay
        study.studyTime = studyTime

        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
}
