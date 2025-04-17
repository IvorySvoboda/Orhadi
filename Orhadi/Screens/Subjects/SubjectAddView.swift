//
//  SubjectAddView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 16/04/25.
//

import SwiftUI

struct SubjectAddView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let startTimeDate: Date = {
        var components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour],
            from: Date()
        )
        components.year = 0
        components.month = 1
        components.day = 1
        components.hour = 7
        return Calendar.current.date(from: components)!
    }()

    let scheduleDate: Date = {
        var components = Calendar.current.dateComponents(
            [.year, .month, .weekday],
            from: Date()
        )
        components.year = 0
        components.month = 1
        components.weekday = components.weekday
        return Calendar.current.date(from: components)!
    }()

    var isRecess: Bool

    @State private var subject: Subject
    @State private var selectedWeekday: Int

    init(isRecess: Bool) {
        self.isRecess = isRecess
        _subject = State(initialValue: Subject(
            name: "",
            teacher: nil,
            schedule: scheduleDate,
            startTime: startTimeDate,
            endTime: startTimeDate + 3000,
            place: "",
            isRecess: self.isRecess
        ))
        _selectedWeekday = State(initialValue: Calendar.current.component(.weekday, from: scheduleDate))
    }

    var body: some View {
        NavigationStack {
            Form {
                if !isRecess {
                    Section {
                        TextField("Minha nova matéria", text: $subject.name)
                            .autocorrectionDisabled()

                        SubjectTeacherPicker(subject: subject)

                        TextField("Sala 101", text: $subject.place)
                            .autocorrectionDisabled()
                    } header: {
                        Text("Nova Matéria")
                    }.listRowBackground(
                        OrhadiTheme.getSecondaryBGColor(for: colorScheme)
                    )
                }

                Section {
                    Picker("Dia:", selection: $selectedWeekday) {
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
                isRecess
                    ? String(localized: "Novo Intervalo")
                    : String(localized: "Nova Matéria")
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        addItem()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
    }

    private func addItem() {
        withAnimation {
            modelContext.insert(subject)
        }
    }
}
