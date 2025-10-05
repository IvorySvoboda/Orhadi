//
//  SubjectSheetView.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 20/04/25.
//

import SwiftData
import SwiftUI
import WidgetKit

struct SubjectSheetView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var teacher: Teacher?
    @State private var schedule: Date
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var place: String
    @State private var isRecess: Bool

    @Bindable var subject: Subject
    var isNew: Bool

    private var navigationTitle: String {
        if isNew {
            return subject.isRecess ? "New Interval" : "New Subject"
        } else {
            return "Edit \(subject.isRecess ? "Interval" : "Subject")"
        }
    }

    // MARK: - INIT

    init(subject: Subject, isNew: Bool) {
        self.subject = subject
        self.isNew = isNew

        _name = State(initialValue: subject.name)
        _teacher = State(initialValue: subject.teacher)
        _schedule = State(initialValue: subject.schedule)
        _startTime = State(initialValue: subject.startTime)
        _endTime = State(initialValue: subject.endTime)
        _place = State(initialValue: subject.place)
        _isRecess = State(initialValue: subject.isRecess)
    }

    // MARK: - Views

    var body: some View {
        NavigationStack {
            Form {
                if !subject.isRecess {
                    subjectInfoSection
                    teacherSelectionSection
                }
                timeSelectionSection
            }
            .orhadiListStyle()
            .navigationTitle("\(isNew ? String(localized: "New") : String(localized: "Edit")) \(subject.isRecess ? String(localized: "Interval") : String(localized: "Subject"))")
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
                        dismiss()

                        if isNew {
                            addItem()
                            UINotificationFeedbackGenerator()
                                .notificationOccurred(.success)
                        } else {
                            subject.name = name
                            subject.teacher = teacher
                            subject.schedule = schedule
                            subject.startTime = startTime
                            subject.endTime = endTime
                            subject.place = place
                            UIImpactFeedbackGenerator(style: .soft)
                                .impactOccurred()
                        }

                        WidgetCenter.shared.reloadAllTimelines()
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
                    .disabled(name.isEmpty && !isRecess)
                }
            }
        }
    }

    private var subjectInfoSection: some View {
        Section {
            HStack {
                Text("Name")
                    .frame(width: 50, alignment: .leading)
                TextField("English", text: $name)
                    .autocorrectionDisabled()
            }
            HStack {
                Text("Place")
                    .frame(width: 50, alignment: .leading)
                TextField("Room 101", text: $place)
                    .autocorrectionDisabled()
            }
        }
    }

    private var teacherSelectionSection: some View {
        Section {
            TeacherPickerView(teacher: $teacher)
        }
    }

    private var timeSelectionSection: some View {
        Section {
            Picker("Weekday", selection: Binding(
                get: { Calendar.current.component(.weekday, from: schedule) },
                set: { newWeekday in
                    let currentWeekday = Calendar.current.component(.weekday, from: schedule)
                    let diff = newWeekday - currentWeekday
                    if let newDate = Calendar.current.date(byAdding: .day, value: diff, to: schedule) {
                        schedule = newDate
                    }
                })
            ) {
                ForEach(1...7, id: \.self) { index in
                    let name = Calendar.current.weekdaySymbols[index - 1].capitalized
                    
                    Text(name).tag(index)
                }
            }.pickerStyle(.navigationLink)

            HStack {
                Text("From – To")

                Spacer()

                DatePicker(
                    "From",
                    selection: $startTime,
                    displayedComponents: [.hourAndMinute]
                )
                .labelsHidden()

                Text(" – ")

                DatePicker(
                    "To",
                    selection: $endTime,
                    displayedComponents: [.hourAndMinute]
                )
                .labelsHidden()
                .onChange(of: endTime) { _, newDate in
                    /// se a nova data for menor que a data de inicio, define `endTime` para `startTime + 60 (1 minuto)`
                    if newDate <= startTime {
                        endTime = startTime + 60
                    }
                }
            }
        } header: {
            Text("Time")
        }
    }

    // MARK: - Functions

    private func addItem() {
        withAnimation {
            if !isRecess {
                /// Procura uma matéria no banco de dados.
                let existingSubjects = try? context.fetch(
                    FetchDescriptor<Subject>(
                        predicate: #Predicate {
                            $0.name == name
                        }
                    )
                )

                /// Se não tiver nenhuma matéria com o mesmo nome da matéria a ser adicionada,
                /// adiciona ele na Study Routine também.
                if let existingSubjects, existingSubjects.isEmpty {
                    context.insert(
                        SRStudy(
                            name: name,
                            studyDay: schedule
                        )
                    )
                }
            }

            context.insert(
                Subject(
                    name: name,
                    teacher: teacher,
                    schedule: schedule,
                    startTime: startTime,
                    endTime: endTime,
                    place: place,
                    isRecess: isRecess
                )
            )
        }
    }
}
