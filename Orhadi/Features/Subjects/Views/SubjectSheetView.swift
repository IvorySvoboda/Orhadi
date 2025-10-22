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

    @State private var showAlert: Bool = false
    @State private var name: String
    @State private var teacher: Teacher?
    @State private var schedule: Date
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var place: String

    @Bindable var subject: Subject
    var isNew: Bool

    private var navigationTitle: LocalizedStringKey {
        if isNew {
            return subject.isRecess ? "New Interval" : "New Subject"
        } else {
            return subject.isRecess ? "Edit Interval" : "Edit Subject"
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
    }

    // MARK: - Views

    var body: some View {
        NavigationStack {
            Form {
                if !subject.isRecess {
                    Section {
                        TextField("Name (ex: English)", text: $name)
                            .autocorrectionDisabled()

                        TextField("Place (ex: Room 101)", text: $place)
                            .autocorrectionDisabled()

                        TeacherPickerView(teacher: $teacher)
                    }
                }

                Section {
                    Picker("Weekday", selection: Binding(
                        get: { Calendar.current.component(.weekday, from: schedule) },
                        set: { newWeekday in
                            if let newDate = Calendar.current.nextDate(
                                after: schedule,
                                matching: DateComponents(weekday: newWeekday),
                                matchingPolicy: .nextTimePreservingSmallerComponents
                            ) {
                                schedule = newDate
                            }
                        })
                    ) {
                        ForEach(Array(Calendar.current.weekdaySymbols.enumerated()), id: \.offset) { index, name in
                            Text(name.capitalized).tag(index + 1)
                        }
                    }.pickerStyle(.navigationLink)

                    DatePicker("Start", selection: $startTime, displayedComponents: [.hourAndMinute])

                    DatePicker("End", selection: $endTime, displayedComponents: [.hourAndMinute])
                } header: {
                    Text("Schedule")
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark", role: .cancel) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", systemImage: "checkmark") {
                        trySave()
                    }.disabled(name.isEmpty && !subject.isRecess)
                }
            }
            .alert("Schedule Conflict", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("The selected time range is invalid or overlaps with another schedule. Please adjust it before saving.")
            }
        }
    }

    // MARK: - Actions

    private func trySave() {
        let hasConflict = SubjectConflictVerifier.hasConflict(
            id: isNew ? nil : subject.id,
            start: startTime,
            end: endTime,
            schedule: schedule,
            context: context
        )

        if hasConflict {
            showAlert.toggle()
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }

        if isNew {
            insertNewSubject()
        } else {
            applySubjectChanges()
        }

        WidgetCenter.shared.reloadAllTimelines()
        dismiss()
    }

    private func insertNewSubject() {
        withAnimation {
            context.insert(
                Subject(
                    name: name.trimmingCharacters(in: .whitespaces),
                    teacher: teacher,
                    schedule: schedule,
                    startTime: startTime,
                    endTime: endTime,
                    place: place.trimmingCharacters(in: .whitespaces),
                    isRecess: subject.isRecess
                )
            )
        }

        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    private func applySubjectChanges() {
        subject.name = name.trimmingCharacters(in: .whitespaces)
        subject.teacher = teacher
        subject.schedule = schedule
        subject.startTime = startTime
        subject.endTime = endTime
        subject.place = place.trimmingCharacters(in: .whitespaces)

        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
}
