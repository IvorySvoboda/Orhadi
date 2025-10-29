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
    @State private var viewModel: ViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Mr. Johnson", text: $viewModel.draftTeacher.name)
                        .autocorrectionDisabled()
                        .onChange(of: viewModel.draftTeacher.name) { _, _ in
                            viewModel.handleNameChange()
                        }

                    TextField("\(String(localized: "email@exemple.com"))", text: $viewModel.draftTeacher.email)
                        .autocorrectionDisabled()
                }
            }
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", systemImage: "checkmark") {
                        try? viewModel.trySave {
                            dismiss()
                        }
                    }.disabled(viewModel.preventSave)
                }
            }
            .alert("Failed to save!", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorAlertMessage)
            }
        }
    }

    // MARK: - INIT

    init(teacher: Teacher, isNew: Bool) {
        _viewModel = State(initialValue: ViewModel(teacher: teacher, isNew: isNew, dataManager: .shared))
    }
}
