//
//  TeachersView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 16/04/25.
//

import SwiftData
import SwiftUI

struct TeachersView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var context
    @Environment(OrhadiTheme.self) private var theme

    @Query private var subjects: [Subject]
    @Query(sort: \Teacher.name) private var teachers: [Teacher]

    @State private var showAddSheet: Bool = false
    @State private var teacherToEdit: Teacher?

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
            .listRowBackground(theme.secondaryBGColor())
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
                    teacherToEdit = teacher
                } label: {
                    Label("Editar", systemImage: "pencil")
                }
                .tint(.accentColor)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    showAddSheet.toggle()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
        }
        .background(theme.bgColor())
        .scrollContentBackground(.hidden)
        .navigationTitle("Professores")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(
            theme.bgColor(),
            for: .navigationBar)
        .sheet(isPresented: $showAddSheet) {
            TeacherAddView()
                .interactiveDismissDisabled()
        }
        .sheet(item: $teacherToEdit) { teacher in
            TeacherEditView(teacher: teacher)
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

#Preview("TeachersView") {
    NavigationStack {
        TeachersView()
            .modelContainer(SampleData.shared.container)
    }
}

struct TeacherAddView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var context
    @Environment(OrhadiTheme.self) private var theme

    @State private var teacher: Teacher = Teacher(name: "", email: "")
    @State private var preventSave: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Prof. Ivory", text: $teacher.name)
                        .autocorrectionDisabled()
                        .onChange(of: teacher.name) { _, newName in
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
                    TextField("\(String(localized: "email@exemple.com"))", text: $teacher.email)
                        .autocorrectionDisabled()
                } header: {
                    Text("Novo Professor")
                }.listRowBackground(theme.secondaryBGColor())
            }
            .defaultList(theme)
            .navigationTitle("Novo Professor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        addTeacher()
                        dismiss()
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
            context.insert(teacher)
        }
    }
}

struct TeacherEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var context
    @Environment(OrhadiTheme.self) private var theme

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
                }.listRowBackground(theme.secondaryBGColor())
            }
            .defaultList(theme)
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
