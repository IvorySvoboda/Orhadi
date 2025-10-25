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

    init(teacher: Teacher, isNew: Bool, context: ModelContext) {
        _viewModel = State(initialValue: ViewModel(teacher: teacher, isNew: isNew, context: context))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Mr. Johnson", text: $viewModel.draftTeacher.name)
                        .autocorrectionDisabled()
                        .onChange(of: viewModel.draftTeacher.name) { _, newName in
                            viewModel.handleNameChange(newName: newName)
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
                        viewModel.trySave {
                            dismiss()
                        }
                    }.disabled(viewModel.preventSave)
                }
            }
        }
    }
}
