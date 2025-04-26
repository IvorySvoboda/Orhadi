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
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var context
    @Environment(OrhadiTheme.self) private var theme

    @State private var name: String
    @State private var email: String
    @State private var preventSave: Bool = false

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
                            let existingTeacher = try? context.fetch(
                                FetchDescriptor<Teacher>(
                                    predicate: #Predicate { $0.name == newName }
                                )
                            ).first

                            /// Se ja existe um professor com o nome fornecido e
                            /// esse professor não é o mesmo que o professor que
                            /// está sendo editado/adicionado ou o nome fornecido
                            /// está vazio, previne o salvamento.
                            ///
                            /// ao adicionar um professor, o `foundTeacher` nunca
                            /// sera igual ao professor que se sendo adicionado,
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
                } header: {
                    Text("Editar Professor")
                }.listRowBackground(theme.secondaryBGColor())
            }
            .modifier(DefaultList())
            .navigationTitle("\(isNew ? "Novo" : "Editar") Professor(a)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isNew {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancelar") {
                            dismiss()
                        }
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        withAnimation {
                            /// Atualiza as informações do professor
                            teacher.name = name
                            teacher.email = email

                            /// Se for um novo professor, adiciona ele no banco de dados.
                            if isNew {
                                context.insert(teacher)
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                            } else {
                                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                            }
                        }
                        dismiss()
                    }.disabled(preventSave)
                }
            }
        }
    }
}
