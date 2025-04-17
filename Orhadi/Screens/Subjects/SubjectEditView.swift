//
//  SubjectEditView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 16/04/25.
//

import SwiftUI

struct SubjectEditView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var selectedWeekday: Int

    @Bindable var subject: Subject

    init(subject: Subject) {
        self.subject = subject
        _selectedWeekday = State(
            initialValue: Calendar.current.component(
                .weekday,
                from: subject.schedule
            )
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                if !subject.isRecess {
                    Section {
                        TextField("Minha nova matéria", text: $subject.name)
                            .autocorrectionDisabled()

                        SubjectTeacherPicker(subject: subject)

                        TextField("Sala 101", text: $subject.place)
                            .autocorrectionDisabled()
                    } header: {
                        Text("Editar Matéria")
                    }.listRowBackground(
                        OrhadiTheme.getSecondaryBGColor(for: colorScheme)
                    )
                }

                Section {
                    Picker(
                        "Dia:",
                        selection: $selectedWeekday
                    ) {
                        ForEach(1...7, id: \.self) { index in
                            let weekday = Calendar.current.weekdaySymbols[index - 1]
                            Text("\(weekday)").tag(index)
                        }
                    }
                    .onChange(of: selectedWeekday) { oldWeekday, newWeekday in
                        subject.schedule = Calendar.current.date(
                            byAdding: .day,
                            value: newWeekday - oldWeekday,
                            to: subject.schedule
                        )!
                    }

                    DatePicker(
                        "Início:",
                        selection: $subject.startTime,
                        displayedComponents: [.hourAndMinute]
                    )
                    DatePicker(
                        "Fim:",
                        selection: $subject.endTime,
                        displayedComponents: [.hourAndMinute]
                    )
                    .onChange(of: subject.endTime) { _, newDate in
                        if newDate <= subject.startTime {
                            subject.endTime = subject.startTime + 60
                        }
                    }
                } header: {
                    Text("Horário")
                }.listRowBackground(
                    OrhadiTheme.getSecondaryBGColor(for: colorScheme)
                )
            }
            .background(OrhadiTheme.getBGColor(for: colorScheme))
            .scrollContentBackground(.hidden)
            .navigationTitle(
                "Editar \(subject.isRecess ? String(localized: "Intervalo") : String(localized: "Matéria"))"
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        dismiss()
                    }
                }
            }
        }
    }
}
