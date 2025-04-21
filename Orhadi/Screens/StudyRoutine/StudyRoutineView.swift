//
//  SharedStudyRoutineView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 31/03/25.
//

import SwiftData
import SwiftUI

struct SharedStudyRoutineView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(Settings.self) private var settings
    @Environment(OrhadiTheme.self) private var theme

    @Query(sort: \SRSubject.name, animation: .smooth)
    private var subjects: [SRSubject]

    @State private var subjectToEdit: SRSubject?
    @State private var subjectsToStudy: [SRSubject] = []
    @State private var navigateToStudyingView: Bool = false
    @State private var selectedDay: Int = Calendar.current.component(.weekday, from: Date())
    @State private var scrollOffsetY: Int = 151

    var body: some View {
        NavigationStack {
            List {
                GroupedSubjectsList(
                    scrollOffsetY: $scrollOffsetY,
                    selectedDay: $selectedDay,
                    subjects: subjects,
                    dateExtractor: { $0.studyDay }
                ) { subject in
                    SharedStudyRoutineListCell(
                        subject: subject,
                        subjectToEdit: $subjectToEdit,
                        navigateToStudyingView: $navigateToStudyingView,
                        subjectsToStudy: $subjectsToStudy
                    )
                }
            }
            .modifier(DefaultPlainList())
            .navigationTitle("Rotina de Estudos")
            .overlay {
                if subjects.filter({ Calendar.current.component(.weekday, from: $0.studyDay) == selectedDay }).isEmpty && scrollOffsetY < 300 {
                    ContentUnavailableView {
                        Label("Nenhuma Matéria", systemImage: "graduationcap")
                    } description: {
                        Text("Nenhuma matéria hoje. Que tal aproveitar pra descansar um pouco?")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ZStack {
                        Text("Rotina de Estudos")
                            .font(.headline)
                            .opacity(scrollOffsetY < 115 ? 1 : 0)
                            .offset(y: scrollOffsetY <= 70 ? -8 : 0)

                        Text(
                            Calendar.current.weekdaySymbols[selectedDay - 1]
                                .uppercased()
                        )
                        .foregroundStyle(.tint)
                        .font(.caption)
                        .opacity(scrollOffsetY <= 70 ? 1 : 0)
                        .offset(y: scrollOffsetY <= 70 ? 8 : 14)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    let filteredSubjects = subjects.filter {
                        let todayWeekday = Calendar.current.component(
                            .weekday,
                            from: Date()
                        )
                        let studyWeekday = Calendar.current.component(
                            .weekday,
                            from: $0.studyDay
                        )

                        return studyWeekday == todayWeekday
                        && !Calendar.current.isDate($0.lastStudied, equalTo: Date(), toGranularity: .weekOfYear)
                    }

                    Button(action: {
                        guard !filteredSubjects.isEmpty else { return }
                        subjectsToStudy = filteredSubjects
                        navigateToStudyingView.toggle()
                    }) {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                    }
                    .disabled(filteredSubjects.isEmpty)
                }
            }
            .navigationDestination(isPresented: $navigateToStudyingView) {
                StudyingView(subjects: $subjectsToStudy)
            }
            .sheet(item: $subjectToEdit, onDismiss: { subjectToEdit = nil }) { subject in
                SharedSREditView(subject: subject).interactiveDismissDisabled()
            }
        }
    }
}

#Preview("SharedStudyRoutineView") {
    SharedStudyRoutineView()
        .modelContainer(SampleData.shared.container)
        .environment(Settings())
}

struct SharedStudyRoutineListCell: View {
    @Environment(Settings.self) private var settings

    var subject: SRSubject
    @Binding var subjectToEdit: SRSubject?
    @Binding var navigateToStudyingView: Bool
    @Binding var subjectsToStudy: [SRSubject]

    var body: some View {
        HStack {
            if Calendar.current.isDate(
                subject.lastStudied, equalTo: Date(), toGranularity: .weekOfYear)
            {
                Image(systemName: "checkmark")
                    .foregroundStyle(.tint)
            }

            Text(subject.name.isEmpty ? String(localized: "Sem Nome") : subject.name)
            Spacer()
            Text(formatHourAndMinute(subject.studyTime))
                .bold()
        }
        .listRowBackground(Color.clear)
        .swipeActions(edge: .leading) {
            startStudySwipeAction
        }
        .swipeActions(edge: .trailing) {
            editStudySwipeAction
        }
    }

    private var startStudySwipeAction: some View {
        Button(action: {
            subjectsToStudy = [subject]
            navigateToStudyingView.toggle()
        }) {
            Label("Iniciar", systemImage: "play.circle.fill")
        }.tint(.accentColor)
    }

    private var editStudySwipeAction: some View {
        Button(
            action: { subjectToEdit = subject }
        ) {
            Label("Editar", systemImage: "pencil")
        }
        .tint(.accentColor)
    }
}

struct SharedSREditView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(OrhadiTheme.self) private var theme
    @Environment(\.dismiss) private var dismiss
    @Bindable var subject: SRSubject
    @State private var selectedWeekday: Int
    @State private var showConfirmation = false

    init(subject: SRSubject) {
        self.subject = subject
        _selectedWeekday = State(
            initialValue: Calendar.current.component(
                .weekday, from: subject.studyDay
            )
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    CustomDayPickerView(date: $subject.studyDay)

                    DatePicker(
                        "Duração do Estudo",
                        selection: $subject.studyTime,
                        displayedComponents: [.hourAndMinute]
                    )
                } header: {
                    Text("Editar Estudo")
                }.listRowBackground(theme.secondaryBGColor())
            }
            .background(theme.bgColor())
            .scrollContentBackground(.hidden)
            .navigationTitle("Editar Estudo")
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
