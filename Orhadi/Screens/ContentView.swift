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
    @Environment(OrhadiTheme.self) private var theme

    var body: some View {
        TabView {
            Tab("Matérias", systemImage: "book.fill") {
                SubjectsView()
                    .toolbarBackground(theme.bgColor(), for: .tabBar)
            }
            Tab("Tarefas", systemImage: "list.bullet.clipboard.fill") {
                ToDosView()
                    .toolbarBackground(theme.bgColor(), for: .tabBar)
            }
            Tab("Estudos", systemImage: "graduationcap.fill") {
                if settings.sharedSubjects {
                    SharedStudyRoutineView()
                        .toolbarBackground(theme.bgColor(), for: .tabBar)
                } else {
                    StudyRoutineView()
                        .toolbarBackground(theme.bgColor(), for: .tabBar)
                }
            }
            Tab("Ajustes", systemImage: "gearshape.fill") {
                SettingsView(settings: settings)
                    .toolbarBackground(theme.bgColor(), for: .tabBar)
            }
            
        }
        .preferredColorScheme(theme.getTheme(for: settings.theme))
    }
}

#Preview {
    ContentView()
        .modelContainer(SampleData.shared.container)
        .environment(Settings())
}
