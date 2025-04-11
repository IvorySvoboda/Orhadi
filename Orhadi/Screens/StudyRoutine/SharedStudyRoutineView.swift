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

    @Query(sort: [SortDescriptor(\Subject.name)], animation: .smooth)
    private var subjects: [Subject]

    @State private var isEditing: Bool = false
    @State private var subjectToEdit: Subject?
    @State private var subjectsToStudy: [Subject] = []
    @State private var navigateToStudyingView: Bool = false

    var body: some View {
        NavigationStack {
            List {
                GroupedSubjectsList(
                    subjects: subjects.filter { !$0.isHidden && !$0.isRecess },
                    dateExtractor: { $0.studyDay }
                ) { subject in
                    AnyView(
                        SharedStudyRoutineListCell(
                            subject: subject,
                            isEditing: isEditing,
                            subjectToEdit: $subjectToEdit,
                            navigateToStudyingView: $navigateToStudyingView,
                            subjectsToStudy: $subjectsToStudy
                        )
                    )
                }
            }
            .listStyle(PlainListStyle())
            .background(OrhadiTheme.getBGColor(for: colorScheme))
            .navigationTitle("Rotina de Estudos")
            .toolbar {
                if settings.editButton {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            withAnimation(.bouncy(duration: 0.6)) {
                                isEditing.toggle()
                            }
                        }) {
                            Text("\(isEditing ? "OK" : "Editar")")
                        }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        subjectsToStudy = subjects.filter {
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
                            && !$0.isRecess
                        }

                        if !subjectsToStudy.isEmpty {
                            navigateToStudyingView.toggle()
                        }
                    }) {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                    }
                    .disabled(subjects.filter({
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
                        && !$0.isRecess
                    }).isEmpty)
                }
            }
            .toolbarBackground(
                OrhadiTheme.getBGColor(for: colorScheme), for: .navigationBar)
            .navigationDestination(
                isPresented: $navigateToStudyingView,
                destination: {
                    StudyingView(
                        subjects: $subjectsToStudy
                    )
                }
            )

        }
        .sheet(
            item: $subjectToEdit,
            onDismiss: { subjectToEdit = nil }
        ) { subject in
            SharedSREditView(subject: subject).interactiveDismissDisabled()
        }
    }
}

struct SharedStudyRoutineListCell: View {
    @Environment(Settings.self) private var settings

    var subject: Subject
    var isEditing: Bool
    @Binding var subjectToEdit: Subject?
    @Binding var navigateToStudyingView: Bool
    @Binding var subjectsToStudy: [Subject]

    var body: some View {
        ZStack {
            Image(systemName: "pencil.circle.fill")
                .resizable()
                .frame(width: isEditing ? 28 : 18, height: isEditing ? 28 : 18)
                .blur(radius: isEditing ? 0 : 8)
                .offset(x: -155)
                .opacity(isEditing && settings.editButton ? 1 : 0)
                .foregroundStyle(isEditing ? Color.blue : Color.secondary)
                .onTapGesture {
                    guard isEditing && settings.editButton else { return }
                    subjectToEdit = subject
                }

            HStack {
                if Calendar.current.isDate(
                    subject.lastStudied,
                    equalTo: Date(),
                    toGranularity: .weekOfYear)
                {
                    Image(systemName: "checkmark")
                }
                
                Text(subject.name)
                Spacer()
                Text(formatHourAndMinute(subject.studyTime))
                    .bold()
                    .blur(radius: !isEditing || !settings.editButton ? 0 : 8)
                    .opacity(!isEditing || !settings.editButton ? 1 : 0)
                    .scaleEffect(!isEditing || !settings.editButton ? 1 : 0.2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .offset(x: isEditing && settings.editButton ? 45 : 0)
        }
        .listRowBackground(Color.clear)
        .swipeActions(edge: .leading) {
            if settings.swipeActions && (!isEditing || !settings.editButton) {
                Button(action: { subjectToEdit = subject }
                ) {
                    Label(
                        "Editar",
                        systemImage: "pencil"
                    )
                }.tint(.blue)

                Button(action: {
                    subjectsToStudy = [subject]

                    navigateToStudyingView.toggle()
                }) {
                    Label(
                        "Iniciar",
                        systemImage: "play.circle.fill"
                    )
                }.tint(.gray)
            }
        }
    }
}

struct SharedSREditView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @Bindable var subject: Subject
    @State private var selectedWeekday: Int
    @State private var showConfirmation = false

    init(subject: Subject) {
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
                    Picker("Dia de Estudo:", selection: $selectedWeekday) {
                        ForEach(
                            Calendar.weekdays.sorted(by: { $0.key < $1.key }), id: \.key
                        ) { key, weekday in
                            Text("\(weekday)").tag(key)
                        }
                    }
                    .onChange(of: selectedWeekday) { oldWeekday, newWeekday in
                        subject.studyDay = Calendar.current.date(
                            byAdding: .day,
                            value: newWeekday - oldWeekday,
                            to: subject.studyDay)!
                    }

                    DatePicker(
                        "Tempo de Estudo:",
                        selection: $subject.studyTime,
                        displayedComponents: [.hourAndMinute]
                    )
                } header: {
                    Text("\(subject.name)")
                }.listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))

                Section {
                    Toggle(
                        "Ocultar",
                        isOn: Binding(
                            get: { subject.isHidden },
                            set: { newValue in
                                if newValue {
                                    showConfirmation = true
                                } else {
                                    subject.isHidden = false
                                }
                            }
                        )
                    )
                    .tint(.green)
                    .alert("Ocultar matéria?", isPresented: $showConfirmation) {
                        Button("Cancelar", role: .cancel) {}
                        Button("Ocultar", role: .destructive) {
                            withAnimation {
                                subject.isHidden = true
                            }
                        }
                    } message: {
                        Text(
                            "Isso removerá a matéria da visualização. Você pode reativá-la a qualquer momento nos ajustes."
                        )
                    }
                } header: {
                    Text("Visualização")
                }.listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))
            }
            .background(OrhadiTheme.getBGColor(for: colorScheme))
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

#Preview("SharedStudyRoutineView") {
    SharedStudyRoutineView()
        .modelContainer(SampleData.shared.container)
        .environment(Settings())
}
