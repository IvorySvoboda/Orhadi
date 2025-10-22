//
//  TeacherSheetView.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 23/04/25.
//

import SwiftData
import SwiftUI

struct TeacherSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var name: String
    @State private var email: String
    @State private var preventSave: Bool = false

    @Bindable var teacher: Teacher
    var isNew: Bool

    private var navigationTitle: LocalizedStringKey {
        if isNew {
            return "New Teacher"
        } else {
            return "Edit Teacher"
        }
    }

    init(teacher: Teacher, isNew: Bool) {
        self.teacher = teacher
        self.isNew = isNew
        _name = State(initialValue: teacher.name)
        _email = State(initialValue: teacher.email)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Mr. Johnson", text: $name)
                        .autocorrectionDisabled()
                        .onChange(of: name) { _, newName in
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

                    TextField("\(String(localized: "email@exemple.com"))", text: $email)
                        .autocorrectionDisabled()
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", systemImage: "checkmark") {
                        trySave()
                    }.disabled(preventSave)
                }
            }
        }
    }

    // MARK: - Actions

    private func trySave() {
        if isNew {
            insertNewTeacher()
        } else {
            applyTeacherChanges()
        }

        dismiss()
    }

    private func insertNewTeacher() {
        withAnimation {
            context.insert(Teacher(
                name: name.trimmingCharacters(in: .whitespaces),
                email: email.trimmingCharacters(in: .whitespaces)
            ))

            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    private func applyTeacherChanges() {
        teacher.name = name.trimmingCharacters(in: .whitespaces)
        teacher.email = email.trimmingCharacters(in: .whitespaces)

        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
}
