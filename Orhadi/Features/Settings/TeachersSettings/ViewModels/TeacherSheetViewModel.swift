//
//  TeacherSheetViewModel.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 23/10/25.
//

import Observation
import SwiftData
import SwiftUI

extension TeacherSheetView {
    @Observable class ViewModel {
        // MARK: - Properties

        private let dataManager: DataManager
        var teacher: Teacher
        var draftTeacher: DraftTeacher
        var isNew: Bool
        var preventSave: Bool = false
        var showErrorAlert = false
        var errorAlertMessage = ""

        // MARK: - Computed Properties

        var navigationTitle: LocalizedStringKey {
            if isNew {
                return "New Teacher"
            } else {
                return "Edit Teacher"
            }
        }

        // MARK: - INIT

        init(teacher: Teacher, isNew: Bool, dataManager: DataManager) {
            self.dataManager = dataManager
            self.teacher = teacher
            self.draftTeacher = DraftTeacher(from: teacher)
            self.isNew = isNew
        }

        // MARK: - Functions

        func handleNameChange() {
            let name = draftTeacher.name.trimmingCharacters(in: .whitespaces)

            let existingTeacher = dataManager.fetchTeachers(
                predicate: #Predicate { $0.name == name }
            ).first

            /// Se ja existe um professor com o nome fornecido e
            /// esse professor não é o mesmo que o professor que
            /// está sendo editado/adicionado ou o nome fornecido
            /// está vazio, previne o salvamento.
            ///
            /// Ao adicionar um professor, o `foundTeacher` nunca
            /// sera igual ao professor que está sendo adicionado,
            /// pois ele ainda não foi adicionado ao Banco de Data.
            if let foundTeacher = existingTeacher, foundTeacher != teacher {
                preventSave = true
            } else if name.isEmpty {
                preventSave = true
            } else {
                preventSave = false
            }
        }

        /// `extraAction()` --> An action to be executed if the save succeeds. Can be used to dismiss the view after the save.
        func trySave(extraAction: @escaping () -> Void) throws {
            do {
                if isNew {
                    try dataManager.addTeacher(Teacher(from: draftTeacher))
                } else {
                    try dataManager.editTeacher(teacher, with: draftTeacher)
                }

                extraAction()
            } catch {
                errorAlertMessage = error.localizedDescription
                showErrorAlert = true
                throw error /// Useful for unit tests.
            }
        }
    }
}
