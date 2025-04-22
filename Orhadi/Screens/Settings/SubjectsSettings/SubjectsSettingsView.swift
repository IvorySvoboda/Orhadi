//
//  SubjectsSettingsView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 01/04/25.
//

import SwiftUI
import SwiftData

struct SubjectsSettingsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(OrhadiTheme.self) private var theme

    @Bindable var settings: Settings

    var body: some View {
        Form {
            Section {
                Toggle("Confirmar para Excluir", isOn: $settings.subjectsDeleteConfirmation)
            }
            .listRowBackground(theme.secondaryBGColor())
        }
        .modifier(DefaultList())
        .navigationTitle("Matérias")
        .navigationBarTitleDisplayMode(.inline)
    }
}
