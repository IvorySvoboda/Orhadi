//
//  StudyView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 27/03/25.
//

import SwiftData
import SwiftUI

struct StudyRoutineView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(Settings.self) private var settings

    @Query(sort: [SortDescriptor(\SRSubject.name)], animation: .smooth)
    private var subjects: [SRSubject]

    @State private var showAddSheet: Bool = false
    @State private var subjectToEdit: SRSubject?
    @State private var subjectsToStudy: [SRSubject] = []
    @State private var navigateToStudyingView: Bool = false
    @State private var selectedDay: Int = Calendar.current.component(
        .weekday,
        from: Date()
    )
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
                    StudyRoutineListCell(
                        subject: subject,
                        subjectToEdit: $subjectToEdit,
                        navigateToStudyingView: $navigateToStudyingView,
                        subjectsToStudy: $subjectsToStudy
                    )
                }
            }
            .overlay {
                if subjects.filter({ Calendar.current.component(.weekday, from: $0.studyDay) == selectedDay }).isEmpty && scrollOffsetY < 300 {
                    ContentUnavailableView {
                        Label("Nenhuma Matéria", systemImage: "graduationcap")
                    } description: {
                        Text("Nenhuma matéria hoje. Que tal aproveitar pra descansar um pouco?")
                    }
                }
            }
            .listStyle(PlainListStyle())
            .background(OrhadiTheme.getBGColor(for: colorScheme))
            .navigationTitle("Rotina de Estudos")
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
                        .foregroundStyle(Color.indigo)
                        .font(.caption)
                        .opacity(scrollOffsetY <= 70 ? 1 : 0)
                        .offset(y: scrollOffsetY <= 70 ? 8 : 14)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showAddSheet.toggle()
                    }) {
                        Image(systemName: "plus.circle.fill").font(.title2)
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

                            return studyWeekday == todayWeekday && !Calendar.current.isDate($0.lastStudied, equalTo: Date(), toGranularity: .weekOfYear)
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

                        return studyWeekday == todayWeekday && !Calendar.current.isDate($0.lastStudied, equalTo: Date(), toGranularity: .weekOfYear)
                    }).isEmpty)
                }
            }
            .toolbarBackground(
                OrhadiTheme.getBGColor(for: colorScheme),
                for: .navigationBar
            )
            .navigationDestination(
                isPresented: $navigateToStudyingView,
                destination: {
                    StudyingView(
                        subjects: $subjectsToStudy
                    )
                }
            )
            .sheet(isPresented: $showAddSheet) {
                SRAddView()
                    .interactiveDismissDisabled()
            }
            .sheet(item: $subjectToEdit) { subject in
                SREditView(subject: subject)
                    .interactiveDismissDisabled()
            }
        }
    }
}

#Preview("StudyRoutineView") {
    StudyRoutineView()
        .modelContainer(SampleData.shared.container)
        .environment(Settings())
}

struct StudyRoutineListCell: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Settings.self) private var settings

    @State private var showConfirmation: Bool = false

    var subject: SRSubject
    @Binding var subjectToEdit: SRSubject?
    @Binding var navigateToStudyingView: Bool
    @Binding var subjectsToStudy: [SRSubject]

    var body: some View {
        HStack {
            if Calendar.current.isDate(
                subject.lastStudied,
                equalTo: Date(),
                toGranularity: .weekOfYear
            ) {
                Image(systemName: "checkmark")
            }
            Text(subject.name.isEmpty ? String(localized: "Não Informado") : subject.name)
            Spacer()
            Text(formatHourAndMinute(subject.studyTime))
                .bold()
        }
        .listRowBackground(Color.clear)
        .swipeActions(edge: .leading) {
            Button(action: {
                subjectsToStudy = [subject]

                navigateToStudyingView.toggle()
            }) {
                Label(
                    "Iniciar",
                    systemImage: "play.circle.fill"
                )
            }
            .tint(.accentColor)
        }
        .swipeActions(edge: .trailing) {
            if settings.srsubjectsDeleteConfirmation {
                Button(action: {
                    showConfirmation.toggle()
                }) {
                    Label("Excluir", systemImage: "trash.fill")
                }.tint(.red)
            }
            if !settings.srsubjectsDeleteConfirmation {
                Button(
                    role: .destructive,
                    action: {
                        deleteSubject(subject: subject)
                    }
                ) {
                    Label("Excluir", systemImage: "trash.fill")
                }
            }
            Button(action: { subjectToEdit = subject }
            ) {
                Label("Editar", systemImage: "pencil")
            }
            .tint(.accentColor)
        }
        .alert("Excluir matéria?", isPresented: $showConfirmation) {
            Button("Cancelar", role: .cancel) {}
            Button("Excluir", role: .destructive) {
                deleteSubject(subject: subject)
            }
        } message: {
            Text(
                "Essa ação é permanente e não pode ser desfeita. Tem certeza de que deseja excluir esta matéria dos estudos?"
            )
        }
    }

    private func deleteSubject(subject: SRSubject) {
        withAnimation {
            modelContext.delete(subject)
        }
    }
}

struct SREditView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @Bindable var subject: SRSubject
    @State private var selectedWeekday: Int

    init(subject: SRSubject) {
        self.subject = subject
        _selectedWeekday = State(
            initialValue: Calendar.current.component(
                .weekday,
                from: subject.studyDay
            )
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Minha matéria", text: $subject.name)
                } header: {
                    Text("Editar Estudo")
                }.listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))

                Section {
                    NavigationLink {
                        SRDayPickerView(selectedWeekday: $selectedWeekday, subject: Binding(
                            get: { subject },
                            set: { _ = $0 }
                        ))
                    } label: {
                        HStack {
                            Text("Dia")
                            Spacer()
                            Text(Calendar.current.weekdaySymbols[selectedWeekday - 1].capitalized)
                                .foregroundStyle(.secondary)
                        }
                    }

                    DatePicker(
                        "Duração do Estudo",
                        selection: $subject.studyTime,
                        displayedComponents: [.hourAndMinute]
                    )
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

struct SRAddView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var selectedWeekday: Int
    @State private var subject: SRSubject

    init() {
        _subject = State(initialValue: SRSubject(
            name: "",
            studyDay: Subject.defaultSchedule(),
            studyTime: Calendar.current.date(
                bySettingHour: 0,
                minute: 30,
                second: 0,
                of: Date()
            )!
        ))
        _selectedWeekday = State(
            initialValue: Calendar.current.component(
                .weekday,
                from: Subject.defaultSchedule()
            )
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Minha nova matéria", text: $subject.name)
                } header: {
                    Text("Nova Matéria")
                }.listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))

                Section {
                    NavigationLink {
                        SRDayPickerView(selectedWeekday: $selectedWeekday, subject: $subject)
                    } label: {
                        HStack {
                            Text("Dia")
                            Spacer()
                            Text(Calendar.current.weekdaySymbols[selectedWeekday - 1].capitalized)
                                .foregroundStyle(.secondary)
                        }
                    }

                    DatePicker(
                        "Duração do Estudo",
                        selection: $subject.studyTime,
                        displayedComponents: [.hourAndMinute]
                    )
                }.listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))
            }
            .background(OrhadiTheme.getBGColor(for: colorScheme))
            .scrollContentBackground(.hidden)
            .navigationTitle("Adicionar Matéria")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        addSRSubject()
                        dismiss()
                    }.disabled(subject.name.isEmpty)
                }
            }
        }
    }

    private func addSRSubject() {
        withAnimation {
            modelContext.insert(subject)
        }
    }
}
