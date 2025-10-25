//
//  TeacherSheetViewModel.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 23/10/25.
//

import SwiftUI
import SwiftData
import Observation

extension TeacherSheetView {
    @Observable class ViewModel {
        var context: ModelContext
        var teacher: Teacher
        var draftTeacher: DraftTeacher
        var isNew: Bool
        var preventSave: Bool = false

        var navigationTitle: LocalizedStringKey {
            if isNew {
                return "New Teacher"
            } else {
                return "Edit Teacher"
            }
        }

        init(teacher: Teacher, isNew: Bool, context: ModelContext) {
            self.context = context
            self.teacher = teacher
            self.draftTeacher = DraftTeacher(from: teacher)
            self.isNew = isNew
        }

        func handleNameChange(newName: String) {
            let name = newName.trimmingCharacters(in: .whitespaces)

            let existingTeacher = try? context.fetch(
                FetchDescriptor<Teacher>(
                    predicate: #Predicate { $0.name == name }
                )
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

        func trySave(extraAction: @escaping () -> Void) {
            if isNew {
                insertNewTeacher()
            } else {
                applyTeacherChanges()
            }

            do {
                try context.save()
                extraAction()
            } catch {
                debugPrint(error.localizedDescription)
            }
        }

        func insertNewTeacher() {
            withAnimation {
                context.insert(Teacher(
                    name: draftTeacher.name.trimmingCharacters(in: .whitespaces),
                    email: draftTeacher.email.trimmingCharacters(in: .whitespaces)
                ))

                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        }

        func applyTeacherChanges() {
            teacher.name = draftTeacher.name.trimmingCharacters(in: .whitespaces)
            teacher.email = draftTeacher.email.trimmingCharacters(in: .whitespaces)

            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
    }
}
