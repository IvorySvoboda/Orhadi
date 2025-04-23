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
            .listRowBackground(theme.secondaryBGColor())
            .swipeActions(edge: .leading) {
                if !teacher.email.isEmpty {
                    Button {
                        if let url = URL(string: "mailto:\(teacher.email)") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
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
                    teacherToAdd = Teacher()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
        }
        .modifier(DefaultList())
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

    private func deleteTeacher(teacher: Teacher) {
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
