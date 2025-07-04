//
//  SRSheetView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 21/04/25.
//

import SwiftUI

struct SRSheetView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var studyDay: Date
    @State private var studyTime: Date

    @Bindable var study: SRStudy
    var isNew: Bool

    init(study: SRStudy, isNew: Bool) {
        self.study = study
        self.isNew = isNew

        _name = State(initialValue: study.name)
        _studyDay = State(initialValue: study.studyDay)
        _studyTime = State(initialValue: study.studyTime)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Nome")
                            .frame(width: 50, alignment: .leading)
                        TextField("Português", text: $name)
                            .autocorrectionDisabled()
                    }
                }.orhadiListRowBackground()

                Section {
                    CustomDayPickerView(date: $studyDay)
                    DatePicker(
                        "Duração do Estudo",
                        selection: $studyTime,
                        displayedComponents: [.hourAndMinute]
                    )
                }.orhadiListRowBackground()
            }
            .orhadiListStyle()
            .navigationTitle("\(isNew ? String(localized: "Novo") : String(localized: "Editar")) Estudo")
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
                        if isNew {
                            addStudy()
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        } else {
                            study.name = name
                            study.studyDay = studyDay
                            study.studyTime = studyTime
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
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
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    private func addStudy() {
        withAnimation {
            context.insert(SRStudy(
                name: name,
                studyDay: studyDay,
                studyTime: studyTime
            ))
        }
    }
}
