// SubjectAddView.swift
// Orhadi

import SwiftUI

struct SubjectAddView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var isRecess: Bool

    @State private var subject: Subject
    @State private var selectedWeekday: Int

    init(isRecess: Bool) {
        self.isRecess = isRecess
        _subject = State(initialValue: Subject(
            name: "",
            teacher: nil,
            schedule: Subject.defaultSchedule(),
            startTime: Subject.defaultStartTime(),
            endTime: Subject.defaultStartTime() + TimeInterval(50 * 60),
            place: "",
            isRecess: self.isRecess
        ))
        _selectedWeekday = State(initialValue: Calendar.current.component(.weekday, from: Subject.defaultSchedule()))
    }

    // MARK: - Views

    var body: some View {
        NavigationStack {
            Form {
                if !isRecess {
                    subjectInfoSection
                    teacherSelectionSection
                }
                timeSelectionSection
            }
            .background(OrhadiTheme.getBGColor(for: colorScheme))
            .scrollContentBackground(.hidden)
            .navigationTitle(isRecess ? String(localized: "Novo Intervalo") : String(localized: "Nova Matéria"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        addItem()
                        dismiss()
                    }.disabled(subject.name.isEmpty && !isRecess)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar", role: .cancel) {
                        dismiss()
                    }
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

    // MARK: - Functions

    private func addItem() {
        withAnimation {
            modelContext.insert(subject)
        }
    }
}
