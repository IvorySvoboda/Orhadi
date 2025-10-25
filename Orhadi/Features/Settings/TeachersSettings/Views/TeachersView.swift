//
//  TeachersView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 16/04/25.
//

import SwiftData
import SwiftUI

struct TeachersView: View {
    @Query(sort: \Teacher.name) private var teachers: [Teacher]
    @Environment(\.modelContext) private var context
    @State private var teacherToAdd: Teacher?
    @State private var teacherToEdit: Teacher?

    var body: some View {
        List(teachers) { teacher in
            TeacherRowView(
                teacher: teacher,
                onEdit: { teacherToEdit = teacher }
            )
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add", systemImage: "plus") {
                    teacherToAdd = Teacher()
                }.tint(.accentColor)
            }
        }
        .navigationTitle("Teachers")
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

#Preview("TeachersView") {
    NavigationStack {
        TeachersView()
            .modelContainer(SampleData.shared.container)
    }
}
