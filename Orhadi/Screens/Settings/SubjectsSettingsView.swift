//
//  SubjectsSettingsView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 01/04/25.
//

import SwiftUI

struct SubjectsSettingsView: View {

    @Bindable var settings: Settings

    var body: some View {
        Form {
            Section {
                Toggle("Confirmar para Excluir", isOn: $settings.subjectsDeleteConfirmation)
                    .tint(.green)
                Toggle(
                    "Arraste para Excluir",
                    isOn: $settings.subjectsDeleteButton
                )
                .tint(.green)
            } header: {
                Text("Geral")
            }
        }
        .navigationTitle("Matérias")
        .navigationBarTitleDisplayMode(.inline)
    }
}
