//
//  TeachersView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 16/04/25.
//

import SwiftData
import SwiftUI

struct TeachersView: View {

    @State private var vm = ViewModel(dataManager: .shared)

    var body: some View {
        List(vm.teachers) { teacher in
            TeacherRowView(
                teacher: teacher,
                onEdit: { vm.teacherToEdit = teacher },
                onDelete: { try? vm.hardDeleteTeacher(teacher) }
            )
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add", systemImage: "plus") {
                    vm.teacherToAdd = Teacher()
                }.tint(.accentColor)
            }
        }
        .navigationTitle("Teachers")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $vm.teacherToAdd) { teacher in
            TeacherSheetView(teacher: teacher, isNew: true)
                .interactiveDismissDisabled()
        }
        .sheet(item: $vm.teacherToEdit) { teacher in
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
