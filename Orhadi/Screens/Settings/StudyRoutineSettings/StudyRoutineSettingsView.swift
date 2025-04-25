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
    @Environment(\.colorScheme) private var colorScheme
    @Environment(OrhadiTheme.self) private var theme

    @Bindable var settings: Settings

    var body: some View {
        Form {
            Section {
                Toggle("Confirmar para Excluir", isOn: $settings.studyDeleteConfirmation)
                BreakTimePickerView()
            }
            .listRowBackground(theme.secondaryBGColor())
        }
        .modifier(DefaultList())
        .navigationTitle("Rotina de Estudos")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BreakTimePickerView: View {
    @Environment(Settings.self) private var settings

    var body: some View {
        NavigationLink {
            BreakTimePicker()
        } label: {
            HStack {
                Text("Tempo de Descanso")
                Spacer()
                Text(formatHourAndMinute(settings.breakTime))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct BreakTimePicker: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @Environment(Settings.self) private var settings
    @Environment(OrhadiTheme.self) private var theme

    var body: some View {
        List {
            Section {
                ForEach(1..<7) { index in
                    Button {
                        settings.breakTime = TimeInterval(300 * index)
                        dismiss()
                    } label: {
                        HStack {
                            Text("\(5 * index)m")
                            Spacer()
                            if settings.breakTime == TimeInterval(300 * index) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                    }.tint(colorScheme == .dark ? .white : .black)
                }
            }.listRowBackground(theme.bgColor())
        }
        .modifier(DefaultList())
        .navigationTitle("Tempo de Descanso")
        .navigationBarTitleDisplayMode(.inline)
    }
}
