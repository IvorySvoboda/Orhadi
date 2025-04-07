//
//  StudyRoutineSettingsView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 01/04/25.
//

import SwiftUI
import SwiftData

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
                ).tint(.green)
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
                    Toggle("Confirmar para Excluir", isOn: $settings.srsubjectsDeleteConfirmation)
                        .tint(.green)
                    Toggle(
                        "Arraste para Excluir",
                        isOn: $settings.srsubjectsDeleteButton
                    )
                    .tint(.green)
                }
            } header: {
                Text("Geral")
            }
            .listRowBackground(Color(red: 0.56, green: 0.56, blue: 0.56, opacity: 0.05))

            if settings.sharedSubjects {
                Section {
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
                                "\(subject.name)",
                                isOn: Binding(
                                    get: { subject.isHidden },
                                    set: { newValue in
                                        withAnimation {
                                            subject.isHidden = newValue
                                        }
                                    }
                                )
                            ).tint(.green)
                        }
                    }
                } header: {
                    Text("Matérias Ocultas")
                }
                .listRowBackground(Color(red: 0.56, green: 0.56, blue: 0.56, opacity: 0.05))
            }
        }
        .background(OrhadiTheme.getBackgroundColor(for: colorScheme))
        .scrollContentBackground(.hidden)
        .navigationTitle("Estudos")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(
            OrhadiTheme.getBackgroundColor(for: colorScheme),
            for: .navigationBar)
    }
}
