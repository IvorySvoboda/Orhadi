//
//  TeacherPickerView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 16/04/25.
//

import SwiftData
import SwiftUI

struct TeacherPickerView: View {

    @Binding var teacher: Teacher?

    // MARK: - Views

    var body: some View {
        NavigationLink {
            TeacherPicker(teacher: $teacher)
        } label: {
            HStack {
                Label("Professor(a)", systemImage: "person.fill")
                Spacer()
                Text(teacher?.name ?? "Nenhum")
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct TeacherPicker: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Teacher.name, animation: .smooth) private var teachers: [Teacher]

    @State private var teacherToAdd: Teacher?
    @State private var teacherToEdit: Teacher?

    @Binding var teacher: Teacher?

    var body: some View {
        List {
            Section {
                ForEach(teachers) { teacher in
                    Button {
                        withAnimation(.smooth(duration: 0.1)) {
                            self.teacher = teacher
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
                            if self.teacher == teacher {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    .tint(.font)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            withAnimation {
                                context.delete(teacher)
                            }
                        } label: {
                            Label("Apagar", systemImage: "trash.fill")
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
            }.listRowBackground(Color.orhadiSecondaryBG)

            Section {
                Button {
                    withAnimation(.smooth(duration: 0.1)) {
                        self.teacher = nil
                        dismiss()
                    }
                } label: {
                    HStack {
                        Text("Nenhum")
                            .foregroundStyle(Color.secondary)
                        Spacer()
                        if self.teacher == nil {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }.tint(.font)
            }.listRowBackground(Color.orhadiSecondaryBG)

            Section {
                Button {
                    teacherToAdd = Teacher()
                } label: {
                    CustomLabel("Novo Professor", systemImage: "plus")
                }
                .tint(Color.accentColor)
            }.listRowBackground(Color.orhadiSecondaryBG)
        }
        .orhadiListStyle()
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
