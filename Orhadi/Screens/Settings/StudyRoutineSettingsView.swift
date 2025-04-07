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
    @Query(animation: .smooth)
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
                    Toggle(
                        "Confirmar para Excluir",
                        isOn: $settings.srsubjectsDeleteConfirmation
                    )
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

            Section {
                NavigationLink("Relatório Semanal") {
                    weeklyReport()
                }
            } header: {
                Text("")
            }

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
            }
        }
        .navigationTitle("Estudos")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct weeklyReport: View {
    @Environment(\.colorScheme) private var colorScheme

    struct ToyShape: Identifiable {
        var color: String
        var day: String
        var totalStudiedHour: Double
        var id = UUID()
    }

    var data: [ToyShape] = [
        .init(color: "Green", day: "Domingo", totalStudiedHour: 1.5),
        .init(color: "Yellow", day: "Domingo", totalStudiedHour: 1),
        .init(color: "Green", day: "Segunda", totalStudiedHour: 0.5),
        .init(color: "Green", day: "Terça", totalStudiedHour: 2),
        .init(color: "Green", day: "Quarta", totalStudiedHour: 0.5),
        .init(color: "Green", day: "Quinta", totalStudiedHour: 3),
        .init(color: "Green", day: "Sexta", totalStudiedHour: 2.5),
        .init(color: "Green", day: "Sábado", totalStudiedHour: 1.5),
    ]

    var body: some View {
        ZStack {
            Color(OrhadiTheme.getBackgroundColor(for: colorScheme))
                .ignoresSafeArea()

            List {
                ForEach(0..<4) { item in
                    NavigationLink("\((1 + item) * 7) de Abril de 2025") {
                        ZStack {
                            Color(
                                OrhadiTheme.getBackgroundColor(for: colorScheme)
                            )
                            .ignoresSafeArea()

                            ScrollView {
                                VStack {
                                    ZStack {
                                        Color(red: 0.56, green: 0.56, blue: 0.56, opacity: 0.05)

                                        VStack {
                                            Text("Total de Horas Estudadas na Semana")
                                                .font(.caption)
                                                .foregroundStyle(Color.secondary)
                                                .padding(.top)

                                            Chart {
                                                ForEach(data) { data in
                                                    BarMark(
                                                        x: .value(
                                                            "Weekday",
                                                            data.day
                                                        ),
                                                        y: .value(
                                                            "Total studied hours",
                                                            data.totalStudiedHour
                                                        )
                                                    )
                                                    .foregroundStyle(by: .value("Shape Color", data.color))
                                                }
                                            }
                                            .chartForegroundStyleScale([
                                                "Green": .green, "Purple": .purple, "Pink": .pink, "Yellow": .yellow
                                            ])
                                            .padding()
                                        }
                                    }
                                    .frame(height: 300)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    .padding()
                                }
                            }
                        }
                        .navigationTitle("\((1 + item) * 7) de Abril de 2025")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbarBackground(
                            OrhadiTheme.getBackgroundColor(for: colorScheme),
                            for: .navigationBar
                        )
                    }.listRowBackground(
                        Color(red: 0.56, green: 0.56, blue: 0.56, opacity: 0.05)
                    )
                }
            }.scrollContentBackground(.hidden)
        }
        .navigationTitle("Relatório Semanal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(
            OrhadiTheme.getBackgroundColor(for: colorScheme),
            for: .navigationBar
        )
    }
}

#Preview("weeklyReport") {
    NavigationStack {
        NavigationLink("Relatório Semanal") {
            weeklyReport()
        }
    }
}
