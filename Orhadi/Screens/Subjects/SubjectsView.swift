//
//  Subjects.swift
//  Orhadi
//
//  Created by Zyvoxi . on 26/03/25.
//

import SwiftData
import SwiftUI

struct SubjectsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Environment(Settings.self) private var settings

    enum SheetType: Identifiable {
        case add
        case edit(Subject)

        var id: String {
            switch self {
            case .add:
                return "add"
            case .edit(let subject):
                return subject.name
            }
        }
    }

    @Query(
        sort: [.init(\Subject.startTime, order: .forward)],
        animation: .bouncy
    )
    private var subjects: [Subject]

    @State private var showConfirmationDialog: Bool = false
    @State private var subjectToEdit: Subject?
    @State private var currentSheet: SheetType?
    @State private var isRecess: Bool = false
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
                    dateExtractor: { $0.schedule }
                ) { subject in
                    AnyView(
                        SubjectListCell(
                            subject: subject,
                            currentSheet: $currentSheet)
                    )
                }
            }
            .listStyle(PlainListStyle())
            .background(OrhadiTheme.getBGColor(for: colorScheme))
            .navigationTitle("Matérias")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ZStack {
                        Text("Matérias")
                            .font(.headline)
                            .opacity(minY < 115 ? 1 : 0)
                            .offset(y: minY <= 70 ? -8 : 0)

                        Text(
                            Calendar.current.weekdaySymbols[selectedDay - 1]
                                .uppercased()
                        )
                        .foregroundStyle(Color.indigo)
                        .font(.caption)
                        .opacity(minY <= 70 ? 1 : 0)
                        .offset(y: minY <= 70 ? 8 : 14)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showConfirmationDialog.toggle()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .confirmationDialog(
                "Adicionar",
                isPresented: $showConfirmationDialog
            ) {
                Button("Matéria") {
                    currentSheet = .add
                }
                Button("Intervalo") {
                    isRecess = true
                    currentSheet = .add
                }
                Button("Cancelar", role: .cancel) {}
            }
            .toolbarBackground(
                OrhadiTheme.getBGColor(for: colorScheme),
                for: .navigationBar
            )
        }
        .sheet(
            item: $currentSheet,
            onDismiss: {
                isRecess = false
            }
        ) { sheetType in
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
    @Binding var currentSheet: SubjectsView.SheetType?

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            if subject.isRecess {
                HStack {
                    Text("INTERVALO")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontWeight(.semibold)
                    Image(systemName: "clock.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(
                        "\(formatTime(subject.startTime)) – \(formatTime(subject.endTime))"
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.semibold)
                }
            } else {
                Text(
                    subject.name.isEmpty
                        ? String(localized: "Sem Nome") : subject.name
                )
                .font(.headline)
                .fontWeight(.semibold)

                VStack(alignment: .leading, spacing: 2) {
                    if let teacher = subject.teacher {
                        if !teacher.name.isEmpty {
                            HStack {
                                Image(systemName: "person.fill")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.trailing, 1)
                                Text(teacher.name)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        if !teacher.email.isEmpty {
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.trailing, -3)
                                Text(teacher.email)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .frame(maxWidth: 125, alignment: .leading)
                            }
                        }
                    }

                    HStack {
                        Image(systemName: "clock.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(
                            "\(formatTime(subject.startTime)) – \(formatTime(subject.endTime))"
                        )
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
        .listRowBackground(Color.clear)
        .swipeActions(edge: .leading) {
            if let teacher = subject.teacher, !teacher.email.isEmpty {
                Button(action: {
                    let name = subject.name.isEmpty ? "Sem Nome" : subject.name
                    let subjectEncoded =
                    name.addingPercentEncoding(
                        withAllowedCharacters: .urlQueryAllowed
                    ) ?? ""
                    
                    if let url = URL(
                        string:
                            "mailto:\(teacher.email)?subject=\(subjectEncoded)"
                    ) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Image(systemName: "envelope.fill")
                }.tint(.accentColor)
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if settings.subjectsDeleteConfirmation {
                Button(action: {
                    showConfirmation.toggle()
                }) {
                    Image(systemName: "trash.fill")
                }.tint(.red)
            }
            if !settings.subjectsDeleteConfirmation {
                Button(
                    role: .destructive,
                    action: {
                        deleteSubject(subject: subject)
                    }
                ) {
                    Image(systemName: "trash.fill")
                }
            }

            Button(action: { currentSheet = .edit(subject) }) {
                Image(systemName: "pencil")
            }.tint(.accentColor)
        }
        .alert(
            "Excluir \(subject.isRecess ? String(localized: "intervalo") : String(localized: "matéria"))?",
            isPresented: $showConfirmation
        ) {
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

struct SubjectTeacherPicker: View {
    @Environment(\.colorScheme) private var colorScheme

    @Query private var teachers: [Teacher]

    @Bindable var subject: Subject

    var body: some View {
        NavigationLink {
            List {
                Section {
                    ForEach(teachers) { teacher in
                        Button {
                            withAnimation(.smooth(duration: 0.1)) {
                                subject.teacher = teacher
                            }
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(teacher.name)
                                        .font(.headline)
                                }
                                Spacer()
                                if subject.teacher == teacher {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }.tint(colorScheme == .dark ? .white : .black)
                    }
                }.listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))

                Section {
                    Button {
                        withAnimation(.smooth(duration: 0.1)) {
                            subject.teacher = nil
                        }
                    } label: {
                        HStack {
                            Text("Nenhum")
                                .foregroundStyle(Color.secondary)
                            Spacer()
                            if subject.teacher == nil {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }.tint(colorScheme == .dark ? .white : .black)
                }.listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))
            }
            .navigationTitle("Professor")
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .background(OrhadiTheme.getBGColor(for: colorScheme))
        } label: {
            HStack {
                Text("Professor")
                Spacer()
                Text(subject.teacher?.name ?? "Nenhum")
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct SubjectEditView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @Query private var teachers: [Teacher]

    @State private var selectedWeekday: Int

    @Bindable var subject: Subject

    init(subject: Subject) {
        self.subject = subject
        _selectedWeekday = State(
            initialValue: Calendar.current.component(
                .weekday,
                from: subject.schedule
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

                        SubjectTeacherPicker(subject: subject)

                        TextField("Sala 101", text: $subject.place)
                            .autocorrectionDisabled()
                    } header: {
                        Text("Editar Matéria")
                    }.listRowBackground(
                        OrhadiTheme.getSecondaryBGColor(for: colorScheme)
                    )
                }

                Section {
                    Picker(
                        "Dia:",
                        selection: $selectedWeekday
                    ) {
                        ForEach(1...7, id: \.self) { index in
                            let weekday = Calendar.current.weekdaySymbols[index - 1]
                            Text("\(weekday)").tag(index)
                        }
                    }
                    .onChange(of: selectedWeekday) { oldWeekday, newWeekday in
                        subject.schedule = Calendar.current.date(
                            byAdding: .day,
                            value: newWeekday - oldWeekday,
                            to: subject.schedule
                        )!
                    }

                    DatePicker(
                        "Início:",
                        selection: $subject.startTime,
                        displayedComponents: [.hourAndMinute]
                    )
                    DatePicker(
                        "Fim:",
                        selection: $subject.endTime,
                        displayedComponents: [.hourAndMinute]
                    )
                    .onChange(of: subject.endTime) { _, newDate in
                        if newDate <= subject.startTime {
                            subject.endTime = subject.startTime + 60
                        }
                    }
                } header: {
                    Text("Horário")
                }.listRowBackground(
                    OrhadiTheme.getSecondaryBGColor(for: colorScheme)
                )
            }
            .background(OrhadiTheme.getBGColor(for: colorScheme))
            .scrollContentBackground(.hidden)
            .navigationTitle(
                "Editar \(subject.isRecess ? String(localized: "Intervalo") : String(localized: "Matéria"))"
            )
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

    @Query private var teachers: [Teacher]

    let startTimeDate: Date = {
        var components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour],
            from: Date()
        )
        components.year = 0
        components.month = 1
        components.day = 1
        components.hour = 7
        return Calendar.current.date(from: components)!
    }()

    let scheduleDate: Date = {
        var components = Calendar.current.dateComponents(
            [.year, .month, .weekday],
            from: Date()
        )
        components.year = 0
        components.month = 1
        components.weekday = components.weekday
        return Calendar.current.date(from: components)!
    }()

    var isRecess: Bool

    @State private var subject: Subject
    @State private var selectedWeekday: Int

    init(isRecess: Bool) {
        self.isRecess = isRecess
        _subject = State(initialValue: Subject(
            name: "",
            teacher: nil,
            schedule: scheduleDate,
            startTime: startTimeDate,
            endTime: startTimeDate + 3000,
            place: "",
            isRecess: self.isRecess
        ))
        _selectedWeekday = State(initialValue: Calendar.current.component(.weekday, from: scheduleDate))
    }

    var body: some View {
        NavigationStack {
            Form {
                if !isRecess {
                    Section {
                        TextField("Minha nova matéria", text: $subject.name)
                            .autocorrectionDisabled()

                        SubjectTeacherPicker(subject: subject)

                        TextField("Sala 101", text: $subject.place)
                            .autocorrectionDisabled()
                    } header: {
                        Text("Nova Matéria")
                    }.listRowBackground(
                        OrhadiTheme.getSecondaryBGColor(for: colorScheme)
                    )
                }

                Section {
                    Picker("Dia:", selection: $selectedWeekday) {
                        ForEach(1...7, id: \.self) { index in
                            let weekday = Calendar.current.weekdaySymbols[index - 1]
                            Text("\(weekday)").tag(index)
                        }
                    }
                    .onChange(of: selectedWeekday) { oldWeekday, newWeekday in
                        subject.schedule = Calendar.current.date(
                            byAdding: .day,
                            value: newWeekday - oldWeekday,
                            to: subject.schedule
                        )!
                    }

                    DatePicker(
                        "Início:",
                        selection: $subject.startTime,
                        displayedComponents: [.hourAndMinute]
                    )
                    DatePicker(
                        "Fim:",
                        selection: $subject.endTime,
                        displayedComponents: [.hourAndMinute]
                    )
                    .onChange(of: subject.endTime) { _, newDate in
                        if newDate <= subject.startTime {
                            subject.endTime = subject.startTime + 60
                        }
                    }

                } header: {
                    Text("Horário")
                }.listRowBackground(
                    OrhadiTheme.getSecondaryBGColor(for: colorScheme)
                )
            }
            .background(OrhadiTheme.getBGColor(for: colorScheme))
            .scrollContentBackground(.hidden)
            .navigationTitle(
                isRecess
                    ? String(localized: "Novo Intervalo")
                    : String(localized: "Nova Matéria")
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        addItem()
                        dismiss()
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
        withAnimation {
            modelContext.insert(subject)
        }
    }
}

#Preview("SubjectsView") {
    SubjectsView()
        .modelContainer(SampleData.shared.container)
        .environment(Settings())
}
