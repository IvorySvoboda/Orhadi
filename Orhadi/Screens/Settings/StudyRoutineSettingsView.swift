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
            .listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))

            Section {
                NavigationLink("Relatório Semanal") {
                    WeeklyReportView()
                }
            }
            .listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))

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
                .listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))
            }
        }
        .background(OrhadiTheme.getBackgroundColor(for: colorScheme))
        .scrollContentBackground(.hidden)
        .navigationTitle("Estudos")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(
            OrhadiTheme.getBackgroundColor(for: colorScheme),
            for: .navigationBar
        )
    }
}

struct WeeklyReportView: View {
    @Environment(\.colorScheme) private var colorScheme

    @Query private var weeklyReports: [WeeklyReport]

    var body: some View {
        List {
            ForEach(weeklyReports) { weeklyReport in
                NavigationLink("7 de Abril de 2025") {
                    ZStack {
                        Color(
                            OrhadiTheme.getBackgroundColor(for: colorScheme)
                        )
                        .ignoresSafeArea()

                        ScrollView {
                            VStack {
                                StudiedHoursChart(data: weeklyReport.studiedHoursChartData)
                                MostStudiedSubjectsByDayChart(data: weeklyReport.mssByDayChartData)
                                TotalStudiedSubjectsByDayChart(data: weeklyReport.tssByDayChartData)

                                HStack {
                                    Text("Orhadi © Zyvoxi Industries")
                                }.padding(.bottom).font(.caption).foregroundStyle(Color.secondary)
                            }
                        }
                    }
                    .navigationTitle("7 de Abril de 2025")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(
                        OrhadiTheme.getBackgroundColor(for: colorScheme),
                        for: .navigationBar
                    )
                }.listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))
            }
        }
        .background(OrhadiTheme.getBackgroundColor(for: colorScheme))
        .scrollContentBackground(.hidden)
        .navigationTitle("Relatório Semanal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(
            OrhadiTheme.getBackgroundColor(for: colorScheme),
            for: .navigationBar
        )
    }
}

struct StudiedHoursChart: View {
    @Environment(\.colorScheme) private var colorScheme

    var data: [StudiedHoursChartData]

    var body: some View {
        ZStack {
            OrhadiTheme.getSecondaryBGColor(for: colorScheme)

            VStack {
                Text("Total de Horas Estudadas por Dia")
                    .font(.footnote)
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
                    }
                    RuleMark(
                        y: .value("Meta", 0.5)
                    ).foregroundStyle(.red)
                }
                .chartYScale(domain: [0, 3])
                .chartForegroundStyleScale([
                    "Horas estudadas": Color
                        .accentColor,
                    "Meta diaria": .red,
                ])
                .padding()
            }
        }
        .frame(height: 300)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 10,
                style: .continuous
            )
        )
        .padding()
    }
}

struct MostStudiedSubjectsByDayChart: View {
    @Environment(\.colorScheme) private var colorScheme

    var data: [MSSByDayChartData]

    var body: some View {
        ZStack {
            OrhadiTheme.getSecondaryBGColor(for: colorScheme)

            VStack {
                Text("Matérias mais Estudada por Dia")
                    .font(.footnote)
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
                        .annotation(position: .top, alignment: .center, spacing: 5) {
                            Text(data.subject)
                                .font(.caption)
                                .foregroundColor(Color.secondary)
                                .lineLimit(1)
                                .frame(width: 43)
                        }
                    }
                }
                .chartYScale(domain: [0, 3])
                .chartForegroundStyleScale([
                    "Horas estudadas": Color.accentColor,
                ])
                .padding()
            }
        }
        .frame(height: 300)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 10,
                style: .continuous
            )
        )
        .padding()
    }
}

struct TotalStudiedSubjectsByDayChart: View {
    @Environment(\.colorScheme) private var colorScheme

    var data: [TSSByDayChartData]

    var body: some View {
        ZStack {
            OrhadiTheme.getSecondaryBGColor(for: colorScheme)
            
            VStack {
                Text("Total de Matérias Estudadas por Dia")
                    .font(.footnote)
                    .foregroundStyle(Color.secondary)
                    .padding(.top)
                
                Chart(data) { data in
                        BarMark(
                            x: .value(
                                "Dia da Semana",
                                data.day
                            ),
                            y: .value(
                                "Matérias Estudadas",
                                data.totalSubjectsStudied
                            )
                        )
                    
                }
                .chartYScale(domain: [0, 4])
                .chartForegroundStyleScale([
                    "Horas estudadas": Color.accentColor
                ])
                .padding()
            }
        }
        .frame(height: 300)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 10,
                style: .continuous
            )
        )
        .padding()
    }
}

#Preview("weeklyReport") {
    NavigationStack {
        NavigationLink("Relatório Semanal") {
            WeeklyReportView()
        }
    }
}
