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
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
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
            HStack() {
                Text("Nome")
                    .frame(width: 50, alignment: .leading)
                TextField("Minha nova matéria", text: $subject.name)
                    .autocorrectionDisabled()
            }
            HStack() {
                Text("Local")
                    .frame(width: 50, alignment: .leading)
                TextField("Sala 101", text: $subject.place)
                    .autocorrectionDisabled()
            }
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
            NavigationLink {
                SubjectDayPickerView(selectedWeekday: $selectedWeekday, subject: subject)
            } label: {
                HStack {
                    Text("Dia")
                    Spacer()
                    Text(Calendar.current.weekdaySymbols[selectedWeekday - 1].capitalized)
                        .foregroundStyle(.secondary)
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
