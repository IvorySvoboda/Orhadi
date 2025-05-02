//
//  SubjectsSettingsView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 01/04/25.
//

import SwiftUI
import SwiftData

struct SubjectsSettingsView: View {

    @Bindable var settings: Settings

    var body: some View {
        Form {
            Section {
                Toggle("Confirmar para Excluir", isOn: $settings.subjectsDeleteConfirmation)
            }
            .listRowBackground(Color.orhadiSecondaryBG)
        }
        .orhadiListStyle()
        .navigationTitle("Matérias")
        .navigationBarTitleDisplayMode(.inline)
    }
}
