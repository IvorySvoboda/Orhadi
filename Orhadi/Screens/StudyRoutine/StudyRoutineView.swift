//
//  StudyView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 27/03/25.
//

import SwiftData
import SwiftUI

enum StudyRoutineSheetType: Identifiable {
    case add
    case edit(SRSubject)

    var id: String {
        switch self {
        case .add:
            return "add"
        case .edit(let subject):
            return subject.id
        }
    }
}

struct StudyRoutineView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(Settings.self) private var settings

    @Query(sort: [SortDescriptor(\SRSubject.name)], animation: .smooth)
    private var subjects: [SRSubject]

    @State private var isEditing: Bool = false
    @State private var currentSheet: StudyRoutineSheetType? = nil
    @State private var subjectsToStudy: [SRSubject] = []
    @State private var navigateToStudyingView: Bool = false
    @State private var selectedDay: Int = Calendar.current.component(
        .weekday,
        from: Date()
    )
    @State private var minY: Int = 151

    var body: some View {
        NavigationStack {
            List {
                GroupedSubjectsList(
                    minY: $minY,
                    selectedDay: $selectedDay,
                    subjects: subjects,
                    dateExtractor: { $0.studyDay }
                ) { subject in
                    AnyView(
                        StudyRoutineListCell(
                            subject: subject,
                            currentSheet: $currentSheet,
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
                ToolbarItem(placement: .principal) {
                    ZStack {
                        Text("Rotina de Estudos")
                            .font(.headline)
                            .opacity(minY < 115 ? 1 : 0)
                            .offset(y: minY <= 70 ? -10 : 0)

                        Text(
                            Calendar.current.weekdaySymbols[selectedDay - 1]
                                .uppercased()
                        )
                        .foregroundStyle(Color.indigo)
                        .font(.caption)
                        .opacity(minY <= 70 ? 1 : 0)
                        .offset(y: 8)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        currentSheet = .add
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
        }
        .sheet(item: $currentSheet) { sheetType in
            switch sheetType {
            case .add:
                SRAddView().interactiveDismissDisabled()
            case .edit(let subject):
                SREditView(subject: subject).interactiveDismissDisabled()
            }
        }
    }
}

struct StudyRoutineListCell: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Settings.self) private var settings

    @State private var showConfirmation: Bool = false

    var subject: SRSubject
    @Binding var currentSheet: StudyRoutineSheetType?
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
            Button(action: { currentSheet = .edit(subject) }
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

                    Picker("Dia:", selection: $selectedWeekday) {
                        ForEach(
                            Calendar.weekdays.sorted(by: { $0.key < $1.key }),
                            id: \.key
                        ) { key, weekday in
                            Text("\(weekday)").tag(key)
                        }
                    }
                    .onChange(of: selectedWeekday) { oldWeekday, newWeekday in
                        subject.studyDay = Calendar.current.date(
                            byAdding: .day,
                            value: newWeekday - oldWeekday,
                            to: subject.studyDay
                        )!
                    }

                    DatePicker(
                        "Tempo:",
                        selection: $subject.studyTime,
                        displayedComponents: [.hourAndMinute]
                    )
                } header: {
                    Text("\(subject.name)")
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
    @State private var name: String = ""
    @State private var studyDay: Int
    @State private var studyTime: Date = Calendar.current.date(
        bySettingHour: 0,
        minute: 30,
        second: 0,
        of: Date()
    )!

    init() {
        _studyDay = State(
            initialValue: Calendar.current.component(.weekday, from: Date())
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Minha nova matéria", text: $name)
                    Picker("Dia:", selection: $studyDay) {
                        ForEach(
                            Calendar.weekdays.sorted(by: { $0.key < $1.key }),
                            id: \.key
                        ) { key, weekday in
                            Text("\(weekday)").tag(key)
                        }
                    }

                    DatePicker(
                        "Tempo:",
                        selection: $studyTime,
                        displayedComponents: [.hourAndMinute]
                    )
                } header: {
                    Text("Nova Matéria")
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
                    }.bold()
                }
            }
        }
    }

    private func addSRSubject() {
        let currentWeekday = Calendar.current.component(.weekday, from: Date())
        let newSRSubject = SRSubject(
            name: name,
            studyDay: Calendar.current.date(
                byAdding: .weekday,
                value: studyDay - currentWeekday,
                to: Date()
            )!,
            studyTime: studyTime
        )

        withAnimation {
            modelContext.insert(newSRSubject)
        }

        dismiss()
    }
}

#Preview("StudyRoutineView") {
    StudyRoutineView()
        .modelContainer(SampleData.shared.container)
        .environment(Settings())
}
