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
    @Environment(OrhadiTheme.self) private var theme

    @Bindable var subject: SRSubject
    var isNew: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Nome")
                            .frame(width: 50, alignment: .leading)
                        TextField("Português", text: $subject.name)
                            .autocorrectionDisabled()
                    }
                }.listRowBackground(theme.secondaryBGColor())

                Section {
                    CustomDayPickerView(date: $subject.studyDay)
                    DatePicker(
                        "Duração do Estudo",
                        selection: $subject.studyTime,
                        displayedComponents: [.hourAndMinute]
                    )
                }.listRowBackground(theme.secondaryBGColor())
            }
            .modifier(DefaultList())
            .navigationTitle("\(isNew ? String(localized: "Novo") : String(localized: "Editar")) Estudo")
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
                        dismiss()
                        if isNew {
                            addSubject()
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        } else {
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        }
                    }.disabled(subject.name.isEmpty)
                }
            }
        }
    }

    private func addSubject() {
        withAnimation {
            context.insert(subject)
        }
    }
}
