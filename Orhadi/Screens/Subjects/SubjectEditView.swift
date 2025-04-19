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
            initialValue: Calendar.current.component(.weekday, from: subject.schedule)
        )
    }

    // MARK: - Views

    var body: some View {
        NavigationStack {
            Form {
                if !subject.isRecess {
                    subjectInfoSection
                }

                teacherSelectionSection

                timeSelectionSection
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
                    }.disabled(subject.name.isEmpty && !subject.isRecess)
                }
            }
        }
    }

    private var subjectInfoSection: some View {
        Section {
            TextField("Minha nova matéria", text: $subject.name)
                .autocorrectionDisabled()
            TextField("Sala 101", text: $subject.place)
                .autocorrectionDisabled()
        } header: {
            Text("Nova Matéria")
        }.listRowBackground(
            OrhadiTheme.getSecondaryBGColor(for: colorScheme)
        )
    }

    private var teacherSelectionSection: some View {
        Section {
            NavigationLink {
                SubjectTeacherPickerView(subject: subject)
            } label: {
                HStack {
                    Text("Professor")
                    Spacer()
                    Text(subject.teacher?.name ?? "Nenhum")
                        .foregroundColor(.secondary)
                }
            }
        }.listRowBackground(
            OrhadiTheme.getSecondaryBGColor(for: colorScheme)
        )
    }

    private var timeSelectionSection: some View {
        Section {
            Picker("Dia", selection: $selectedWeekday) {
                ForEach(1...7, id: \.self) { index in
                    let weekday = Calendar.current.weekdaySymbols[index - 1]
                    Text(weekday).tag(index)
                }
            }
            .onChange(of: selectedWeekday) { oldWeekday, newWeekday in
                if let newDate = Calendar.current.date(
                    byAdding: .day,
                    value: newWeekday - oldWeekday,
                    to: subject.schedule
                ) {
                    subject.schedule = newDate
                }
            }

            HStack {
                Text("Das")

                Spacer()

                DatePicker("", selection: $subject.startTime, displayedComponents: [.hourAndMinute])
                    .labelsHidden()

                Text(" – ")

                DatePicker("", selection: $subject.endTime, displayedComponents: [.hourAndMinute])
                    .labelsHidden()
                    .onChange(of: subject.endTime) { _, newDate in
                        if newDate <= subject.startTime {
                            subject.endTime = subject.startTime + 60
                        }
                    }
            }
        } header: {
            Text("Horário")
        }.listRowBackground(
            OrhadiTheme.getSecondaryBGColor(for: colorScheme)
        )
    }
}
