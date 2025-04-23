//
//  SubjectTeacherPickerView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 16/04/25.
//

import SwiftData
import SwiftUI

struct SubjectTeacherPickerView: View {

    @Bindable var subject: Subject

    // MARK: - Views

    var body: some View {
        NavigationLink {
            SubjectTeacherPicker(subject: subject)
        } label: {
            HStack {
                Text("Professor(a)")
                Spacer()
                Text(subject.teacher?.name ?? "Nenhum")
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct SubjectTeacherPicker: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(OrhadiTheme.self) private var theme

    @Query(sort: \Teacher.name, animation: .smooth) private var teachers: [Teacher]

    @State private var teacherToAdd: Teacher?
    @State private var teacherToEdit: Teacher?

    @Bindable var subject: Subject

    var body: some View {
        List {
            Section {
                ForEach(teachers) { teacher in
                    Button {
                        withAnimation(.smooth(duration: 0.1)) {
                            subject.teacher = teacher
                        }
                        dismiss()
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(teacher.name)
                                    .font(.headline)
                                if !teacher.email.isEmpty {
                                    CustomLabel("\(teacher.email)", systemImage: "envelope.fill")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            if subject.teacher == teacher {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    .tint(colorScheme == .dark ? .white : .black)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            withAnimation {
                                context.delete(teacher)
                            }
                        } label: {
                            Label("Excluir", systemImage: "trash.fill")
                                .labelStyle(.iconOnly)
                        }

                        Button {
                            teacherToEdit = teacher
                        } label: {
                            Label("Editar", systemImage: "pencil")
                                .labelStyle(.iconOnly)
                        }.tint(Color.accentColor)
                    }
                }
            }.listRowBackground(theme.secondaryBGColor())

            Section {
                Button {
                    withAnimation(.smooth(duration: 0.1)) {
                        subject.teacher = nil
                        dismiss()
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
            }.listRowBackground(theme.secondaryBGColor())

            Section {
                Button {
                    teacherToAdd = Teacher()
                } label: {
                    CustomLabel("Novo Professor", systemImage: "plus")
                }
                .tint(Color.accentColor)
            }.listRowBackground(theme.secondaryBGColor())
        }
        .modifier(DefaultList())
        .navigationTitle("Professor(a)")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $teacherToAdd) { teacher in
            TeacherSheetView(teacher: teacher, isNew: true)
                .interactiveDismissDisabled()
        }
        .sheet(item: $teacherToEdit) { teacher in
            TeacherSheetView(teacher: teacher, isNew: false)
                .interactiveDismissDisabled()
        }
    }
}
