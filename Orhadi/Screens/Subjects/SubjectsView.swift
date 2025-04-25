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
    @Environment(OrhadiTheme.self) private var theme
    @Environment(\.modelContext) private var modelContext
    @Environment(Settings.self) private var settings

    @Query(sort: \Subject.startTime, animation: .smooth) private var subjects: [Subject]

    @State private var showConfirmationDialog = false
    @State private var subjectToAdd: Subject?
    @State private var subjectToEdit: Subject?
    @State private var showDeleteConfirmation = false
    @State private var selectedDay = Calendar.current.component(.weekday, from: Date())
    @State private var scrollOffsetY = 151

    // MARK: - Views

    var body: some View {
        NavigationStack {
            List {
                GroupedSubjectsList(
                    scrollOffsetY: $scrollOffsetY,
                    selectedDay: $selectedDay,
                    subjects: subjects,
                    dateExtractor: { $0.schedule }
                ) { subject in
                    SubjectRow(
                        subject: subject,
                        subjectToAdd: $subjectToAdd,
                        subjectToEdit: $subjectToEdit)
                }
            }
            .modifier(DefaultPlainList())
            .navigationTitle("Matérias")
            .toolbar {
                ToolbarItem(placement: .principal) { principalToolbar }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showConfirmationDialog.toggle() }) {
                        Image(systemName: "plus.circle.fill").font(.title2)
                    }
                }
            }
            .overlay { overlay }
            .confirmationDialog("", isPresented: $showConfirmationDialog) {
                ForEach([
                    (title: "Adicionar Matéria", isRecess: false),
                    (title: "Adicionar Intervalo", isRecess: true)
                ], id: \.title) { option in
                    Button(option.title) {
                        showConfirmationDialog = false
                        subjectToAdd = Subject(isRecess: option.isRecess)
                    }
                }
                Button("Cancelar", role: .cancel) {}
            }
            .sheet(item: $subjectToAdd) { subject in
                SubjectSheetView(subject: subject, isNew: true)
                    .interactiveDismissDisabled()
            }
            .sheet(item: $subjectToEdit) { subject in
                SubjectSheetView(subject: subject, isNew: false)
                    .interactiveDismissDisabled()
            }
        }
    }

    // MARK: Toolbar

    private var principalToolbar: some View {
        ZStack {
            Text("Matérias")
                .font(.headline)
                .opacity(scrollOffsetY < 115 ? 1 : 0)
                .offset(y: scrollOffsetY <= 70 ? -8 : 0)

            Text(Calendar.current.weekdaySymbols[selectedDay - 1].uppercased())
                .foregroundStyle(.tint)
                .font(.caption)
                .opacity(scrollOffsetY <= 70 ? 1 : 0)
                .offset(y: scrollOffsetY <= 70 ? 8 : 14)
        }
    }

    // MARK: Overlay

    private var overlay: some View {
        Group {
            if subjects.filter({ Calendar.current.component(.weekday, from: $0.schedule) == selectedDay }).isEmpty && scrollOffsetY < 300 {
                ContentUnavailableView {
                    Label("Nenhuma Matéria", systemImage: "book")
                } description: {
                    Text("Nenhuma matéria hoje. Que tal aproveitar pra descansar um pouco?")
                }
            }
        }
    }
}

struct SubjectRow: View {
    @Environment(\.modelContext) private var context
    @Environment(Settings.self) private var settings
    @Environment(OrhadiTheme.self) private var theme

    @State private var showDeleteConfirmation = false

    var subject: Subject
    @Binding var subjectToAdd: Subject?
    @Binding var subjectToEdit: Subject?

    // MARK: - Views

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            if subject.isRecess {
                HStack {
                    Text("INTERVALO")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fontWeight(.semibold)
                    CustomLabel("\(formatTime(subject.startTime)) – \(formatTime(subject.endTime))", systemImage: "clock.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fontWeight(.semibold)
                }
            } else {
                Text(subject.name.nilIfEmpty() ?? String(localized: "Sem Nome"))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .frame(maxWidth: 200, alignment: .leading)

                VStack(alignment: .leading, spacing: 2) {
                    if let teacher = subject.teacher {
                        if !teacher.name.isEmpty {
                            CustomLabel("\(teacher.name)", systemImage: "person.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        if !teacher.email.isEmpty {
                            CustomLabel("\(teacher.email)", systemImage: "envelope.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    CustomLabel("\(formatTime(subject.startTime)) – \(formatTime(subject.endTime))", systemImage: "clock.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if !subject.place.isEmpty {
                        CustomLabel("\(subject.place)", systemImage: "building.2.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .listRowBackground(Color.clear)
        .swipeActions(edge: .leading) {
            sendEmailSwipeAction
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            deleteSwipeAction
            duplicateSwipeAction
            editSwipeAction
        }
        .alert("Excluir \(subject.isRecess ? "intervalo" : "matéria")?",
               isPresented: $showDeleteConfirmation
        ) {
            Button("Cancelar", role: .cancel) {}
            Button("Excluir", role: .destructive) {
                deleteSubject()
            }
        } message: {
            Text("Essa ação é permanente e não pode ser desfeita. Tem certeza de que deseja excluir \(subject.isRecess ? "este intervalo" : "esta matéria")?")
        }
    }

    // MARK: Swipe Actions

    private var sendEmailSwipeAction: some View {
        Group {
            /// se existe um professor na matéria e o email do professor não está vazio
            /// crie o botão para enviar um email
            if let teacher = subject.teacher, !teacher.email.isEmpty {
                Button(action: { openMail(to: teacher.email) }) {
                    Label("Enviar e-mail", systemImage: "envelope.fill")
                        .labelStyle(.iconOnly)
                }.tint(.accentColor)
            }
        }
    }

    private var deleteSwipeAction: some View {
        Group {
            // Cria o botão adequado para as configurações do usuário
            if settings.subjectsDeleteConfirmation {
                Button(action: { showDeleteConfirmation.toggle() }) {
                    Label("Excluir", systemImage: "trash.fill")
                        .labelStyle(.iconOnly)
                }
                .tint(.red)
            } else {
                Button(role: .destructive, action: { deleteSubject() }) {
                    Label("Excluir", systemImage: "trash.fill")
                        .labelStyle(.iconOnly)
                }
            }
        }
    }

    private var duplicateSwipeAction: some View {
        Button {
            subjectToAdd = Subject(
                name: subject.name,
                teacher: subject.teacher,
                schedule: subject.schedule,
                startTime: subject.startTime + 1,
                endTime: subject.endTime + 1,
                place: subject.place,
                isRecess: subject.isRecess)
        } label: {
            Label("Duplicar", systemImage: "rectangle.fill.on.rectangle.angled.fill")
                .labelStyle(.iconOnly)
        }.tint(.teal)
    }

    private var editSwipeAction: some View {
        Button { subjectToEdit = subject } label: {
            Label("Editar", systemImage: "pencil")
                .labelStyle(.iconOnly)
        }.tint(.accentColor)
    }

    // MARK: - Funcitons

    private func openMail(to email: String) {
        guard let encoded = subject.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "mailto:\(email)?subject=\(encoded)") else { return }
        UIApplication.shared.open(url)
    }

    private func deleteSubject() {
        withAnimation(.bouncy) {
            context.delete(subject)
        }
    }
}
