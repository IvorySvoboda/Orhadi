//
//  SubjectSheetView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 20/04/25.
//

import SwiftData
import SwiftUI
import WidgetKit

struct SubjectSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var vm: ViewModel

    // MARK: - INIT

    init(subject: Subject, isNew: Bool = false) {
        _vm = State(initialValue: ViewModel(subject: subject, isNew: isNew, dataManager: .shared))
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                subjectInfoSection
                subjectTeacherSection
                scheduleSection
            }
            .navigationTitle(vm.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarComponents }
            .alert("Failed to save!", isPresented: $vm.showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(vm.errorAlertMessage)
            }
        }
    }

    // Form Components

    @ViewBuilder private var subjectInfoSection: some View {
        if !vm.subject.isRecess {
            Section {
                TextField("Name (ex: English)", text: $vm.draftSubject.name)
                    .autocorrectionDisabled()

                TextField("Place (ex: Room 101)", text: $vm.draftSubject.place)
                    .autocorrectionDisabled()
            }
        }
    }

    @ViewBuilder private var subjectTeacherSection: some View {
        if !vm.subject.isRecess {
            Section {
                TeacherPicker(teacher: $vm.draftSubject.teacher)
            } header: {
                Text("Teacher")
            }
        }
    }

    private var scheduleSection: some View {
        Section {
            WeekdayPicker(selection: $vm.draftSubject.schedule)

            DatePicker("Start", selection: $vm.draftSubject.startTime, displayedComponents: [.hourAndMinute])

            DatePicker("End", selection: $vm.draftSubject.endTime, displayedComponents: [.hourAndMinute])
        } header: {
            Text("Schedule")
        }
    }

    // MARK: - Toolbar

    private var toolbarComponents: some ToolbarContent {
        Group {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark", role: .cancel) {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save", systemImage: "checkmark") {
                    try? vm.trySave {
                        dismiss()
                    }
                }.disabled(!vm.canSave)
            }
        }
    }
}
