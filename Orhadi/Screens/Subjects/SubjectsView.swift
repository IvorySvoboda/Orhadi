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

    @State private var showConfirmationDialog: Bool = false
    @State private var subjectToEdit: Subject?
    @State private var currentSheet: SubjectsSheetType? = nil
    @State private var isEditing: Bool = false
    @State private var isRecess: Bool = false

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
            .background(OrhadiTheme.getBGColor(for: colorScheme))
            .navigationTitle("Matérias")
            .toolbar {
                if !settings.editButton {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            showConfirmationDialog.toggle()
                        }) {
                            Image(systemName: "plus.circle.fill").font(.title2)
                        }
                    }
                }
                if settings.editButton {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            if isEditing {
                                showConfirmationDialog.toggle()
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
            .confirmationDialog("Adicionar", isPresented: $showConfirmationDialog ,actions: {
                Button("Matéria") {
                    currentSheet = .add
                }
                Button("Intervalo") {
                    isRecess = true
                    currentSheet = .add
                }
                Button("Cancelar", role: .cancel) {}
            })
            .toolbarBackground(
                OrhadiTheme.getBGColor(for: colorScheme),
                for: .navigationBar)
        }
        .sheet(
            item: $currentSheet,
            onDismiss: {
                isRecess = false
            }) { sheetType in
                switch sheetType {
                case .add:
                    SubjectAddView(isRecess: isRecess).interactiveDismissDisabled()
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
                .foregroundStyle(isEditing ? .accentColor : Color.secondary)
                .onTapGesture {
                    guard isEditing && settings.editButton else { return }
                    currentSheet = .edit(subject)
                }

            VStack(alignment: .leading, spacing: 3) {
                if subject.isRecess {
                    Text("Intervalo")
                        .font(.headline)
                        .fontWeight(.semibold)
                    HStack {
                        Image(systemName: "clock.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(formatTime(subject.startTime)) - \(formatTime(subject.endTime))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text(subject.name.isEmpty ? String(localized: "Sem Nome") : subject.name)
                        .font(.headline)
                        .fontWeight(.semibold)

                    VStack(alignment: .leading, spacing: 2) {
                        if !subject.teacher.isEmpty {
                            HStack {
                                Image(systemName: "person.fill")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.trailing, 1)
                                Text(subject.teacher)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        if !subject.email.isEmpty {
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.trailing, -3)
                                Text(subject.email)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        HStack {
                            Image(systemName: "clock.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(formatTime(subject.startTime)) - \(formatTime(subject.endTime))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        if !subject.place.isEmpty {
                            HStack {
                                Image(systemName: "location.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(subject.place)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
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
                    guard settings.subjectsDeleteConfirmation && (isEditing && settings.editButton) else {
                        return deleteSubject(subject: subject)
                    }
                    showConfirmation.toggle()
                }
        }
        .listRowBackground(Color.clear)
        .swipeActions(edge: .leading) {
            if settings.swipeActions && (!isEditing || !settings.editButton) {
                Button(action: { currentSheet = .edit(subject) }) {
                    Image(systemName: "pencil")
                }.tint(.accentColor)

                if !subject.email.isEmpty {
                    Button(action: {
                        let name = subject.name.isEmpty ? "Sem Nome" : subject.name
                        let subjectEncoded = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

                        if let url = URL(string: "mailto:\(subject.email)?subject=\(subjectEncoded)") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Image(systemName: "envelope.fill")
                    }.tint(Color(.darkGray))
                }
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
        .alert("Excluir \(subject.isRecess ? String(localized: "intervalo") : String(localized: "matéria"))?", isPresented: $showConfirmation) {
            Button("Cancelar", role: .cancel) {}
            Button("Excluir", role: .destructive) {
                deleteSubject(subject: subject)
            }
        } message: {
            Text(
                "Essa ação é permanente e não pode ser desfeita. Tem certeza de que deseja excluir \(subject.isRecess ? String(localized: "este intervalo") : String(localized: "esta matéria"))?"
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
    @Environment(\.colorScheme) private var colorScheme
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
                if !subject.isRecess {
                    Section {
                        TextField("Minha nova matéria", text: $subject.name)
                            .autocorrectionDisabled()
                        TextField("Prof. Ivory", text: $subject.teacher)
                            .autocorrectionDisabled()
                        TextField("\("email@exemple.com")", text: $subject.email)
                            .autocorrectionDisabled()

                        TextField("Sala 101", text: $subject.place)
                            .autocorrectionDisabled()
                    } header: {
                        Text("\(subject.name)")
                    }.listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))
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
                    .onChange(of: subject.endTime) { _, newDate in
                        if newDate <= subject.startTime {
                            subject.endTime = subject.startTime + 60
                        }
                    }
                } header: {
                    Text("Horário")
                }.listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))
            }
            .background(OrhadiTheme.getBGColor(for: colorScheme))
            .scrollContentBackground(.hidden)
            .navigationTitle("Editar \(subject.isRecess ? String(localized: "Intervalo") : String(localized: "Matéria"))")
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
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var subjects: [Subject]

    @State private var name: String = ""
    @State private var teacher: String = ""
    @State private var email: String = ""
    @State private var schedule: Date = Date()
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var place: String = ""
    @State private var selectedWeekday: Int = Calendar.current.component(.weekday, from: Date())

    var isRecess: Bool

    init(isRecess: Bool) {
        let startTimeDate: Date = {
            var components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour], from: Date())
            components.year = 0
            components.month = 1
            components.day = 1
            components.hour = 7
            return Calendar.current.date(from: components)!
        }()

        _startTime = State(initialValue: startTimeDate)
        _endTime = State(initialValue: startTimeDate + 3000)
        self.isRecess = isRecess
    }

    var body: some View {
        NavigationStack {
            Form {
                if !isRecess {
                    Section {
                        TextField("Minha nova matéria", text: $name)
                            .autocorrectionDisabled()
                        TextField("Prof. Ivory", text: $teacher)
                            .autocorrectionDisabled()
                        TextField("\("email@exemple.com")", text: $email)
                            .autocorrectionDisabled()

                        TextField("Sala 101", text: $place)
                            .autocorrectionDisabled()
                    } header: {
                        Text("Nova Matéria")
                    }.listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))
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
                    .onChange(of: endTime) { _, newDate in
                        if newDate <= startTime {
                            endTime = startTime + 60
                        }
                    }

                } header: {
                    Text("Horário")
                }.listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))
            }
            .background(OrhadiTheme.getBGColor(for: colorScheme))
            .scrollContentBackground(.hidden)
            .navigationTitle(isRecess ? String(localized: "Novo Intervalo") : String(localized: "Nova Matéria"))
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
            place: place,
            isRecess: isRecess
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
