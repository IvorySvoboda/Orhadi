//
//  TeachersView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 16/04/25.
//

import SwiftData
import SwiftUI

struct TeachersView: View {

    @State private var viewModel = ViewModel(dataManager: .shared)

    var body: some View {
        List(viewModel.teachers) { teacher in
            TeacherRowView(
                teacher: teacher,
                onEdit: { viewModel.teacherToEdit = teacher },
                onDelete: { try? viewModel.hardDeleteTeacher(teacher) }
            )
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add", systemImage: "plus") {
                    viewModel.teacherToAdd = Teacher()
                }.tint(.accentColor)
            }
        }
        .navigationTitle("Teachers")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $viewModel.teacherToAdd) { teacher in
            TeacherSheetView(teacher: teacher, isNew: true)
                .interactiveDismissDisabled()
        }
        .sheet(item: $viewModel.teacherToEdit) { teacher in
            TeacherSheetView(teacher: teacher, isNew: false)
                .interactiveDismissDisabled()
        }
    }
}

#Preview("TeachersView") {
    NavigationStack {
        TeachersView()
            .modelContainer(DataManager.shared.container)
    }
}
