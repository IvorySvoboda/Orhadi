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
    @Query(sort: [SortDescriptor(\Subject.name)], animation: .smooth)
    private var subjects: [Subject]

    @Bindable var settings: Settings

    var body: some View {
        Form {
            Section {
                Toggle(
                    "Matérias Compartilhadas",
                    isOn: Binding(
                        get: { settings.sharedSubjects },
                        set: { newValue in
                            withAnimation(.smooth) {
                                settings.sharedSubjects = newValue
                            }
                        }
                    )
                )
                Picker(
                    "Tempo de Descanso",
                    selection: $settings.breakTime
                ) {
                    Text("5m").tag(TimeInterval(300))
                    Text("10m").tag(TimeInterval(600))
                    Text("15m").tag(TimeInterval(900))
                    Text("20m").tag(TimeInterval(1200))
                    Text("25m").tag(TimeInterval(1500))
                    Text("30m").tag(TimeInterval(1800))
                }
                if !settings.sharedSubjects {
                    Toggle(
                        "Confirmar para Excluir",
                        isOn: $settings.srsubjectsDeleteConfirmation
                    )
                }
            }
            .listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))

            if settings.sharedSubjects {
                Section {
                    NavigationLink("Matérias Ocultas") {
                        Form {
                            let hiddenSubjects = subjects.filter {
                                $0.isHidden == true
                            }

                            if hiddenSubjects.isEmpty {
                                VStack {
                                    Text("Sem matérias ocultas.")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }.animation(.smooth, value: subjects)
                            }

                            ForEach(hiddenSubjects) { subject in
                                HStack {
                                    Image(systemName: "eye.slash.fill")
                                        .font(.title2)
                                        .foregroundStyle(Color.secondary)
                                    Toggle(
                                        "\(subject.name.isEmpty ? "Sem Nome" : subject.name)",
                                        isOn: Binding(
                                            get: { subject.isHidden },
                                            set: { newValue in
                                                withAnimation {
                                                    subject.isHidden = newValue
                                                }
                                            }
                                        )
                                    )
                                }
                                .listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))
                            }
                        }
                        .navigationTitle("Matérias Ocultas")
                        .navigationBarTitleDisplayMode(.inline)
                        .background(OrhadiTheme.getBGColor(for: colorScheme))
                        .scrollContentBackground(.hidden)
                        .toolbarBackground(
                            OrhadiTheme.getBGColor(for: colorScheme),
                            for: .navigationBar
                        )
                    }
                }
                .listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))
            }
        }
        .background(OrhadiTheme.getBGColor(for: colorScheme))
        .scrollContentBackground(.hidden)
        .navigationTitle("Rotina de Estudos")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(
            OrhadiTheme.getBGColor(for: colorScheme),
            for: .navigationBar
        )
    }
}
