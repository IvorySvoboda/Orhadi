//
//  TeacherPickerView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 16/04/25.
//

import SwiftData
import SwiftUI

struct SubjectTeacherPickerView: View {

    @Binding var teacher: Teacher?

    // MARK: - Views

    var body: some View {
        NavigationLink {
            SubjectTeacherPicker(teacher: $teacher)
        } label: {
            HStack {
                Label("Teacher", systemImage: "person.fill")
                Spacer()
                Text(teacher?.name ?? String(localized: "None"))
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct SubjectTeacherPicker: View {
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
                            Label("Delete", systemImage: "trash.fill")
                                .labelStyle(.iconOnly)
                        }

                        Button {
                            teacherToEdit = teacher
                        } label: {
                            Label("Edit", systemImage: "pencil")
                                .labelStyle(.iconOnly)
                        }.tint(Color.accentColor)
                    }
                }
            }

            Section {
                Button {
                    withAnimation(.smooth(duration: 0.1)) {
                        self.teacher = nil
                        dismiss()
                    }
                } label: {
                    HStack {
                        Text("None")
                            .foregroundStyle(Color.secondary)
                        Spacer()
                        if self.teacher == nil {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }.tint(.font)
            }

            Section {
                Button {
                    teacherToAdd = Teacher()
                } label: {
                    CustomLabel("New Teacher", systemImage: "plus")
                }
                .tint(Color.accentColor)
            }
        }
        .navigationTitle("Teacher")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $teacherToAdd) { teacher in
            TeacherSheetView(teacher: teacher, isNew: true, context: context)
                .interactiveDismissDisabled()
        }
        .sheet(item: $teacherToEdit) { teacher in
            TeacherSheetView(teacher: teacher, isNew: false, context: context)
                .interactiveDismissDisabled()
        }
    }
}
