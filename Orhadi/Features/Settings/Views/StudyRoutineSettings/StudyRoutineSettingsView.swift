//
//  StudyRoutineSettingsView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 01/04/25.
//

import Charts
import SwiftData
import SwiftUI

struct StudyRoutineSettingsView: View {

    @Bindable var settings: Settings

    var body: some View {
        Form {
            Section {
                Toggle("Confirmar para Excluir", isOn: $settings.studyDeleteConfirmation)
                BreakTimePickerView()
            }
            .listRowBackground(Color.orhadiSecondaryBG)
        }
        .orhadiListStyle()
        .navigationTitle("Rotina de Estudos")
        .navigationBarTitleDisplayMode(.inline)
    }
}
