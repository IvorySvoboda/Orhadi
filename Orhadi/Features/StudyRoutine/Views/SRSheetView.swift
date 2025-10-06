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
    
    private var navigationTitle: String {
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
                    HStack {
                        Text("Name")
                            .frame(width: 50, alignment: .leading)
                        TextField("English", text: $name)
                            .autocorrectionDisabled()
                    }
                }

                Section {
                    Picker("Weekday", selection: Binding(
                        get: { Calendar.current.component(.weekday, from: studyDay) },
                        set: { newWeekday in
                            let currentWeekday = Calendar.current.component(.weekday, from: studyDay)
                            let diff = newWeekday - currentWeekday
                            if let newDate = Calendar.current.date(byAdding: .day, value: diff, to: studyDay) {
                                studyDay = newDate
                            }
                        })
                    ) {
                        ForEach(1...7, id: \.self) { index in
                            let name = Calendar.current.weekdaySymbols[index - 1].capitalized
                            
                            Text(name).tag(index)
                        }
                    }.pickerStyle(.navigationLink)

                    DatePicker(
                        "Study Duration",
                        selection: $studyTime,
                        displayedComponents: [.hourAndMinute]
                    )
                }
            }
            .orhadiListStyle()
            .navigationTitle("\(isNew ? String(localized: "New") : String(localized: "Edit")) Study")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        if #available(iOS 26, *) {
                            Label("Cancel", systemImage: "xmark")
                                .labelStyle(.iconOnly)
                        } else {
                            Label("Cancel", systemImage: "xmark")
                                .labelStyle(.titleOnly)
                        }
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        if isNew {
                            addStudy()
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        } else {
                            study.name = name
                            study.studyDay = studyDay
                            study.studyTime = studyTime
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        }
                        dismiss()
                    } label: {
                        if #available(iOS 26, *) {
                            Label("Save", systemImage: "checkmark")
                                .labelStyle(.iconOnly)
                        } else {
                            Label("Save", systemImage: "checkmark")
                                .labelStyle(.titleOnly)
                        }
                    }
                    .iOS26GlassEffect(tinted: true)
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    private func addStudy() {
        withAnimation {
            context.insert(SRStudy(
                name: name,
                studyDay: studyDay,
                studyTime: studyTime
            ))
        }
    }
}
