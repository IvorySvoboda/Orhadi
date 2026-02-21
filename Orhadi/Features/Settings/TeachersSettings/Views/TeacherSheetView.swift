//
//  TeacherSheetView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 23/04/25.
//

import SwiftData
import SwiftUI

struct TeacherSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var vm: ViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Mr. Johnson", text: $vm.draftTeacher.name)
                        .autocorrectionDisabled()
                        .onChange(of: vm.draftTeacher.name) { _, _ in
                            vm.handleNameChange()
                        }

                    TextField("\(String(localized: "email@exemple.com"))", text: $vm.draftTeacher.email)
                        .autocorrectionDisabled()
                }
            }
            .navigationTitle(vm.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", systemImage: "checkmark") {
                        try? vm.trySave {
                            dismiss()
                        }
                    }.disabled(vm.preventSave)
                }
            }
            .alert("Failed to save!", isPresented: $vm.showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(vm.errorAlertMessage)
            }
        }
    }

    // MARK: - INIT

    init(teacher: Teacher, isNew: Bool) {
        _vm = State(initialValue: ViewModel(teacher: teacher, isNew: isNew, dataManager: .shared))
    }
}
