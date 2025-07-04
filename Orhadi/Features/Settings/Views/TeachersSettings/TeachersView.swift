//
//  TeachersView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 16/04/25.
//

import SwiftData
import SwiftUI

struct TeachersView: View {
    @Environment(\.modelContext) private var context

    @Query private var subjects: [Subject]
    @Query(sort: \Teacher.name) private var teachers: [Teacher]

    @State private var teacherToAdd: Teacher?
    @State private var teacherToEdit: Teacher?

    var body: some View {
        List(teachers) { teacher in
            VStack(alignment: .leading) {
                Text(teacher.name)
                    .font(.headline)
                if !teacher.email.isEmpty {
                    CustomLabel("\(teacher.email)", systemImage: "envelope.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .orhadiListRowBackground()
            .swipeActions(edge: .leading) {
                if !teacher.email.isEmpty {
                    Button {
                        teacher.openMail()
                    } label: {
                        Label("Enviar e-mail", systemImage: "envelope.fill")
                            .labelStyle(.iconOnly)
                    }.tint(.accentColor)
                }
            }
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
                }.tint(.accentColor)
            }
            .contextMenu {
                if !teacher.email.isEmpty {
                    Button {
                        teacher.openMail()
                    } label: {
                        Label("Enviar e-mail", systemImage: "envelope.fill")
                    }
                }

                Button {
                    teacherToEdit = teacher
                } label: {
                    Label("Editar", systemImage: "pencil")
                }

                Button(role: .destructive) {
                    withAnimation {
                        context.delete(teacher)
                    }
                } label: {
                    Label("Apagar", systemImage: "trash.fill")
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    teacherToAdd = Teacher()
                } label: {
                    if #available(iOS 26, *) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundStyle(Color.accentColor)
                    } else {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
        }
        .orhadiListStyle()
        .navigationTitle("Professores")
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

#Preview("TeachersView") {
    NavigationStack {
        TeachersView()
            .modelContainer(SampleData.shared.container)
    }
}
