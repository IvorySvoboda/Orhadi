//
//  SubjectSheetView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 20/04/25.
//

import SwiftUI

struct SubjectSheetView: View {
    @Environment(OrhadiTheme.self) private var theme
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var subject: Subject
    var isNew: Bool

    var body: some View {
        NavigationStack {
            SubjectFormView(subject: subject)
                .navigationTitle(isNew ? subject.isRecess ? "Novo Intervalo" : "Nova Matéria" : "Editar \(subject.isRecess ? "Intervalo" : "Matéria")")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    if isNew {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancelar", role: .cancel) {
                                dismiss()
                            }
                        }
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("Salvar") {
                            dismiss()

                            if isNew {
                                addItem()
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                            } else {
                                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                            }
                        }.disabled(subject.name.isEmpty && !subject.isRecess)
                    }
                }
        }
    }

    private func addItem() {
        withAnimation {
            modelContext.insert(subject)
        }
    }
}
