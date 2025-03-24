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

    var body: some View {
        NavigationStack {
            List {
                GroupedSubjectsList(
                    subjects: subjects,
                    dateExtractor: { $0.studyDay }
                ) { subject in
                    AnyView(
                        StudyRoutineListCell(
                            subject: subject,
                            isEditing: isEditing,
                            currentSheet: $currentSheet,
                            navigateToStudyingView: $navigateToStudyingView,
                            subjectsToStudy: $subjectsToStudy
                        )
                    )
                }
            }
            .listStyle(PlainListStyle())
            .background(OrhadiTheme.getBackgroundColor(for: colorScheme))
            .navigationTitle("Rotina de Estudos")
            .toolbar {
                if !settings.editButton {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            currentSheet = .add
                        }) {
                            Image(systemName: "plus.circle.fill").font(.title2)
                        }
                    }
                }

                if settings.editButton {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            if isEditing {
                                currentSheet = .add
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .blur(radius: isEditing ? 0 : 4)
                        }.opacity(isEditing ? 1 : 0)
                    }
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

                            return studyWeekday == todayWeekday && !Calendar.current.isDate($0.lastStudied, equalTo: Date(), toGranularity: .weekOfYear)
                        }

                        navigateToStudyingView.toggle()
                    }) {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .toolbarBackground(
                OrhadiTheme.getBackgroundColor(for: colorScheme),
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
    var isEditing: Bool
    @Binding var currentSheet: StudyRoutineSheetType?
    @Binding var navigateToStudyingView: Bool
    @Binding var subjectsToStudy: [SRSubject]

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
                    currentSheet = .edit(subject)
                }

            HStack {
                if Calendar.current.isDate(
                    subject.lastStudied,
                    equalTo: Date(),
                    toGranularity: .weekOfYear
                ) {
                    Image(systemName: "checkmark")
                }
                Text(subject.name)
                Spacer()
                Text(formatHourAndMinute(subject.studyTime))
                    .bold()
                    .blur(radius: !isEditing || !settings.editButton ? 0 : 8)
                    .opacity(!isEditing || !settings.editButton ? 1 : 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .offset(x: isEditing && settings.editButton ? 45 : 0)

            Image(systemName: "minus.circle.fill")
                .resizable()
                .frame(width: isEditing ? 28 : 18, height: isEditing ? 28 : 18)
                .blur(radius: isEditing ? 0 : 8)
                .offset(x: 165)
                .opacity(isEditing && settings.editButton ? 1 : 0)
                .font(.title)
                .foregroundStyle(isEditing ? Color.red : Color.secondary)
                .onTapGesture {
                    guard settings.srsubjectsDeleteConfirmation || (isEditing && settings.editButton) else {
                        return deleteSubject(subject: subject)
                    }
                    showConfirmation.toggle()
                }
        }
        .listRowBackground(Color.clear)
        .swipeActions(edge: .leading) {
            if settings.swipeActions && (!isEditing || !settings.editButton) {
                Button(action: { currentSheet = .edit(subject) }
                ) {
                    Label("Editar", systemImage: "pencil")
                }
                .tint(.blue)

                Button(action: {
                    subjectsToStudy = [subject]

                    navigateToStudyingView.toggle()
                }) {
                    Label(
                        "Iniciar",
                        systemImage: "play.circle.fill"
                    )
                }
                .tint(.gray)
            }
        }
        .swipeActions(edge: .trailing) {
            if settings.srsubjectsDeleteConfirmation
                && settings.swipeActions
                && settings.srsubjectsDeleteButton
                && (!isEditing || !settings.editButton)
            {
                Button(action: {
                    showConfirmation.toggle()
                }) {
                    Label("Excluir", systemImage: "trash.fill")
                }.tint(.red)
            }
            if !settings.srsubjectsDeleteConfirmation
                && settings.swipeActions
                && settings.srsubjectsDeleteButton
                && (!isEditing || !settings.editButton)
            {
                Button(
                    role: .destructive,
                    action: {
                        deleteSubject(subject: subject)
                    }
                ) {
                    Label("Excluir", systemImage: "trash.fill")
                }.tint(.red)
            }
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
                }
            }
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
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var name: String = "Minha nova matéria"
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
                }
            }
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
        let newSRSubject = SRSubject(
            name: name,
            studyDay: Calendar.current.date(
                byAdding: .weekday,
                value: studyDay,
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
