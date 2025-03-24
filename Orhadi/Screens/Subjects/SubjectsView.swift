//
//  Subjects.swift
//  Orhadi
//
//  Created by Zyvoxi . on 26/03/25.
//

import SwiftData
import SwiftUI

enum SubjectsSheetType: Identifiable {
    case add
    case edit(Subject)

    var id: String {
        switch self {
        case .add:
            return "add"
        case .edit(let subject):
            return subject.id
        }
    }
}

struct SubjectsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Environment(Settings.self) private var settings

    @Query(
        sort: [.init(\Subject.startTime, order: .forward)],
        animation: .bouncy
    )
    private var subjects: [Subject]

    @State private var subjectToEdit: Subject?
    @State private var currentSheet: SubjectsSheetType? = nil
    @State private var isEditing: Bool = false

    var body: some View {
        NavigationStack {
            List {
                GroupedSubjectsList(
                    subjects: subjects,
                    dateExtractor: { $0.schedule }
                ) { subject in
                    AnyView(
                        SubjectListCell(
                            subject: subject,
                            isEditing: isEditing,
                            currentSheet: $currentSheet
                        )
                    )
                }
            }
            .listStyle(PlainListStyle())
            .background(OrhadiTheme.getBackgroundColor(for: colorScheme))
            .navigationTitle("Matérias")
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
            }
            .toolbarBackground(
                OrhadiTheme.getBackgroundColor(for: colorScheme),
                for: .navigationBar)
        }
        .sheet(item: $currentSheet) { sheetType in
            switch sheetType {
            case .add:
                SubjectAddView().interactiveDismissDisabled()
            case .edit(let subject):
                SubjectEditView(subject: subject).interactiveDismissDisabled()
            }
        }
    }
}

struct SubjectListCell: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Settings.self) private var settings

    @State private var showConfirmation: Bool = false

    var subject: Subject
    var isEditing: Bool
    @Binding var currentSheet: SubjectsSheetType?

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

            VStack(alignment: .leading) {
                Text("\(subject.name)")
                    .font(.headline)
                    .bold()
                Text("\(subject.teacher)")
                    .font(.caption)
                Text("\(subject.email)")
                    .font(.caption)
                Text(
                    "\(formatTime(subject.startTime)) - \(formatTime(subject.endTime))"
                )
                .font(.caption)
                Text("\(subject.place)")
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .offset(x: isEditing && settings.editButton ? 50 : 0)

            Image(systemName: "minus.circle.fill")
                .resizable()
                .frame(width: isEditing ? 28 : 18, height: isEditing ? 28 : 18)
                .blur(radius: isEditing ? 0 : 8)
                .offset(x: 165)
                .opacity(isEditing && settings.editButton ? 1 : 0)
                .font(.title)
                .foregroundStyle(isEditing ? Color.red : Color.secondary)
                .onTapGesture {
                    guard settings.subjectsDeleteConfirmation || (isEditing && settings.editButton) else {
                        return deleteSubject(subject: subject)
                    }
                    showConfirmation.toggle()
                }
        }
        .listRowBackground(Color.clear)
        .swipeActions(edge: .leading) {
            if settings.swipeActions && (!isEditing || !settings.editButton) {
                Button(action: { currentSheet = .edit(subject) }) {
                    Label("Editar", systemImage: "pencil")
                }.tint(.blue)
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if settings.subjectsDeleteConfirmation
                && settings.swipeActions
                && settings.subjectsDeleteButton
                && (!isEditing || !settings.editButton)
            {
                Button(action: {
                    showConfirmation.toggle()
                }) {
                    Label("Excluir", systemImage: "trash.fill")
                }.tint(.red)
            }
            if !settings.subjectsDeleteConfirmation
                && settings.swipeActions
                && settings.subjectsDeleteButton
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
                "Essa ação é permanente e não pode ser desfeita. Tem certeza de que deseja excluir esta matéria?"
            )
        }
    }

    private func deleteSubject(subject: Subject) {
        withAnimation(.bouncy) {
            modelContext.delete(subject)
        }
    }
}

struct SubjectEditView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedWeekday: Int

    @Bindable var subject: Subject

    init(subject: Subject) {
        self.subject = subject
        _selectedWeekday = State(
            initialValue: Calendar.current.component(
                .weekday, from: subject.schedule
            )
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Minha nova matéria", text: $subject.name)
                        .autocorrectionDisabled()
                    TextField("Prof. Ivory", text: $subject.teacher)
                        .autocorrectionDisabled()
                    TextField("email@exemple.com", text: $subject.email)
                        .autocorrectionDisabled()

                    TextField("Sala 101", text: $subject.place)
                        .autocorrectionDisabled()
                } header: {
                    Text("\(subject.name)")
                }

                Section {
                    Picker(
                        "Dia:",
                        selection: $selectedWeekday
                    ) {
                        ForEach(
                            Calendar.weekdays.sorted(by: { $0.key < $1.key }),
                            id: \.key
                        ) { key, weekday in
                            Text("\(weekday)").tag(key)
                        }
                    }
                    .onChange(of: selectedWeekday) { oldWeekday, newWeekday in
                        subject.schedule = Calendar.current.date(
                            byAdding: .day,
                            value: newWeekday - oldWeekday,
                            to: subject.schedule)!
                    }

                    DatePicker(
                        "Início:", selection: $subject.startTime,
                        displayedComponents: [.hourAndMinute])
                    DatePicker(
                        "Fim:", selection: $subject.endTime,
                        displayedComponents: [.hourAndMinute])
                } header: {
                    Text("Horário")
                }
            }
            .navigationTitle("Editar Matéria")
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

struct SubjectAddView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var subjects: [Subject]

    @State private var name: String = String(localized: "Minha nova matéria")
    @State private var teacher: String = String(localized: "Prof. Ivory")
    @State private var email: String = String(localized: "email@exemple.com")
    @State private var schedule: Date
    @State private var startTime: Date = Calendar.current.date(
        bySettingHour: 7, minute: 0, second: 0, of: Date())!
    @State private var endTime: Date = Calendar.current.date(
        bySettingHour: 7, minute: 50, second: 0, of: Date())!
    @State private var place: String = String(localized: "Sala 101")
    @State private var selectedWeekday: Int

    init() {
        let date: Date = {
            var components = Calendar.current.dateComponents(
                [.year, .month, .day], from: Date())
            components.year = 2024
            components.month = 9
            components.day = 1
            return Calendar.current.date(from: components)!
        }()

        _schedule = State(initialValue: date)
        _selectedWeekday = State(
            initialValue: Calendar.current.component(.weekday, from: date)
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Minha nova matéria", text: $name)
                        .autocorrectionDisabled()
                    TextField("Prof. Ivory", text: $teacher)
                        .autocorrectionDisabled()
                    TextField("email@exemple.com", text: $email)
                        .autocorrectionDisabled()

                    TextField("Sala 101", text: $place)
                        .autocorrectionDisabled()
                } header: {
                    Text("Nova Matéria")
                }

                Section {
                    Picker("Dia:", selection: $selectedWeekday) {
                        ForEach(
                            Calendar.weekdays.sorted(by: { $0.key < $1.key }),
                            id: \.key
                        ) { key, weekday in
                            Text("\(weekday)").tag(key)
                        }
                    }
                    .onChange(of: selectedWeekday) { oldWeekday, newWeekday in
                        schedule = Calendar.current.date(
                            byAdding: .day,
                            value: newWeekday - oldWeekday,
                            to: schedule)!
                    }

                    DatePicker(
                        "Início:", selection: $startTime,
                        displayedComponents: [.hourAndMinute])
                    DatePicker(
                        "Fim:", selection: $endTime,
                        displayedComponents: [.hourAndMinute])
                } header: {
                    Text("Horário")
                }
            }
            .navigationTitle("Nova Matéria")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        addItem()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
    }

    private func addItem() {
        let newSubject = Subject(
            name: name,
            teacher: teacher,
            email: email,
            schedule: schedule,
            startTime: startTime,
            endTime: endTime,
            place: place
        )

        withAnimation(.bouncy) {
            modelContext.insert(newSubject)
        }

        dismiss()
    }
}

#Preview("SubjectsView") {
    SubjectsView()
        .modelContainer(SampleData.shared.container)
        .environment(Settings())
}
