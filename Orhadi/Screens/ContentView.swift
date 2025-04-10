//
//  ContentView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 24/03/25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(Settings.self) private var settings

    var body: some View {
        TabView {
            Tab("Matérias", systemImage: "book.fill") {
                SubjectsView()
                    .toolbarBackground(
                        OrhadiTheme.getBGColor(for: colorScheme),
                        for: .tabBar)
            }
            Tab("Tarefas", systemImage: "list.clipboard.fill") {
                ToDosView()
                    .toolbarBackground(
                        OrhadiTheme.getBGColor(for: colorScheme),
                        for: .tabBar)
            }
            Tab("Estudos", systemImage: "graduationcap.fill") {
                if settings.sharedSubjects {
                    SharedStudyRoutineView()
                        .toolbarBackground(
                            OrhadiTheme.getBGColor(
                                for: colorScheme),
                            for: .tabBar)
                } else {
                    StudyRoutineView()
                        .toolbarBackground(
                            OrhadiTheme.getBGColor(
                                for: colorScheme),
                            for: .tabBar)
                }
            }
            Tab("Ajustes", systemImage: "gearshape.fill") {
                SettingsView(settings: settings)
                    .toolbarBackground(
                        OrhadiTheme.getBGColor(
                            for: colorScheme),
                        for: .tabBar)
            }
        }
        .preferredColorScheme(OrhadiTheme.getTheme(for: settings.theme))
        .tint(OrhadiTheme.getAccentColor(from: settings.accentColor))
    }
}

#Preview {
    ContentView()
        .modelContainer(SampleData.shared.container)
        .environment(Settings())
}
