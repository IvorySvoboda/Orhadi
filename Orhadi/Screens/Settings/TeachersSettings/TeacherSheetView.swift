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
                            teacher.name = name
                            teacher.email = email
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
