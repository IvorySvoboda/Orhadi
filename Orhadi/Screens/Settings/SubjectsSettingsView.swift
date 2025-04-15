//
//  SubjectsSettingsView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 01/04/25.
//

import SwiftUI
import SwiftData

struct SubjectsSettingsView: View {
    @Environment(\.colorScheme) private var colorScheme

    @Bindable var settings: Settings

    var body: some View {
        Form {
            Section {
                Toggle("Confirmar para Excluir", isOn: $settings.subjectsDeleteConfirmation)
            }
            .listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))

            Section {
                NavigationLink("Professores") {
                    TeachersView()
                }
            }
            .listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))
        }
        .background(OrhadiTheme.getBGColor(for: colorScheme))
        .scrollContentBackground(.hidden)
        .navigationTitle("Matérias")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(
            OrhadiTheme.getBGColor(for: colorScheme),
            for: .navigationBar)
    }
}

struct TeachersView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var context

    @Query private var subjects: [Subject]

    enum SheetType: Identifiable {
        case add
        case edit(Teacher)

        var id: String {
            switch self {
            case .add:
                return "add"
            case .edit(let teacher):
                return teacher.name
            }
        }
    }

    @Query private var teachers: [Teacher]

    @State private var isAdding: Bool = false
    @State private var currentSheet: SheetType?

    var body: some View {
        List(teachers) { teacher in
            VStack(alignment: .leading) {
                Text(teacher.name)
                    .font(.headline)
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
                            .frame(maxWidth: 150, alignment: .leading)
                    }
                }
            }
            .listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))
            .swipeActions(edge: .leading) {
                if !teacher.email.isEmpty {
                    Button(action: {
                        if let url = URL(
                            string:
                                "mailto:\(teacher.email)"
                        ) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Image(systemName: "envelope.fill")
                    }.tint(.accentColor)
                }
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button(role: .destructive) {
                    deleteTeacher(teacher: teacher)
                } label: {
                    Label("Excluir", systemImage: "trash.fill")
                }
                Button {
                    currentSheet = .edit(teacher)
                } label: {
                    Label("Editar", systemImage: "pencil")
                }
                .tint(.accentColor)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    currentSheet = .add
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
        }
        .background(OrhadiTheme.getBGColor(for: colorScheme))
        .scrollContentBackground(.hidden)
        .navigationTitle("Professores")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(
            OrhadiTheme.getBGColor(for: colorScheme),
            for: .navigationBar)
        .sheet(
            item: $currentSheet,
        ) { sheetType in
            switch sheetType {
            case .add:
                TeacherAddView().interactiveDismissDisabled()
            case .edit(let teacher):
                TeacherEditView(teacher: teacher).interactiveDismissDisabled()
            }
        }
    }

    private func deleteTeacher(teacher: Teacher) {
        for subject in subjects {
            if subject.teacher == teacher {
                subject.teacher = nil
            }
        }

        withAnimation {
            context.delete(teacher)
        }
    }
}

struct TeacherAddView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var context

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var preventSave: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Prof. Ivory", text: $name)
                        .autocorrectionDisabled()
                        .onChange(of: name) { _, newName in
                            let existingTeacher = try? context.fetch(
                                FetchDescriptor<Teacher>(
                                    predicate: #Predicate { $0.name == newName }
                                )
                            ).first

                            if existingTeacher != nil {
                                preventSave = true
                            } else {
                                preventSave = false
                            }
                        }
                    TextField("\(String(localized: "email@exemple.com"))", text: $email)
                        .autocorrectionDisabled()
                } header: {
                    Text("Novo Professor")
                }.listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))
            }
            .background(OrhadiTheme.getBGColor(for: colorScheme))
            .scrollContentBackground(.hidden)
            .navigationTitle("Novo Professor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        addTeacher()
                    }.disabled(preventSave)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
    }

    private func addTeacher() {
        withAnimation {
            context.insert(Teacher(name: name, email: email))
        }
        dismiss()
    }
}

struct TeacherEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var context

    @Bindable var teacher: Teacher

    @State private var name: String
    @State private var email: String
    @State private var preventSave: Bool = false

    init(teacher: Teacher) {
        self.teacher = teacher
        _name = State(initialValue: teacher.name)
        _email = State(initialValue: teacher.email)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Prof. Ivory", text: $name)
                        .autocorrectionDisabled()
                        .onChange(of: name) { _, newName in
                            let existingTeacher = try? context.fetch(
                                FetchDescriptor<Teacher>(
                                    predicate: #Predicate { $0.name == newName }
                                )
                            ).first

                            if let foundTeacher = existingTeacher, foundTeacher != teacher {
                                preventSave = true
                            } else {
                                preventSave = false
                            }
                        }
                    TextField("\(String(localized: "email@exemple.com"))", text: $email)
                        .autocorrectionDisabled()
                } header: {
                    Text("Editar Professor")
                }.listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))
            }
            .background(OrhadiTheme.getBGColor(for: colorScheme))
            .scrollContentBackground(.hidden)
            .navigationTitle("Editar Professor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        withAnimation {
                            teacher.name = name
                            teacher.email = email
                        }
                        dismiss()
                    }.disabled(preventSave)
                }
            }
        }
    }
}
