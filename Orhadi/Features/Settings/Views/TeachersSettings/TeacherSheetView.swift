//
//  TeacherSheetView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 23/04/25.
//

import SwiftData
import SwiftUI

struct TeacherSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var name: String
    @State private var email: String
    @State private var preventSave: Bool = true

    @Bindable var teacher: Teacher
    var isNew: Bool

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
                    TextField("Prof. Ivory", text: $name)
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
                            /// ao adicionar um professor, o `foundTeacher` nunca
                            /// sera igual ao professor que está sendo adicionado,
                            /// pois ele ainda não foi adicionado ao Banco de Dados.
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
                }.orhadiListRowBackground()
            }
            .orhadiListStyle()
            .navigationTitle("\(isNew ? "Novo" : "Editar") Professor(a)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        if #available(iOS 26, *) {
                            Label("Cancelar", systemImage: "xmark")
                                .labelStyle(.iconOnly)
                        } else {
                            Label("Cancelar", systemImage: "xmark")
                                .labelStyle(.titleOnly)
                        }
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        withAnimation {
                            /// Atualiza as informações do professor
                            teacher.name = name.trimmingCharacters(in: .whitespaces)
                            teacher.email = email.trimmingCharacters(in: .whitespaces)

                            /// Se for um novo professor, adiciona ele no banco de dados.
                            if isNew {
                                context.insert(teacher)
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                            } else {
                                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                            }
                        }
                        dismiss()
                    } label: {
                        if #available(iOS 26, *) {
                            Label("Salvar", systemImage: "checkmark")
                                .labelStyle(.iconOnly)
                        } else {
                            Label("Salvar", systemImage: "checkmark")
                                .labelStyle(.titleOnly)
                        }
                    }
                    .iOS26GlassEffect(tinted: true)
                    .disabled(preventSave)
                }
            }
        }
    }
}
