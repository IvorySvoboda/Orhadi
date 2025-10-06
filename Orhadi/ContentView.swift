//
//  ContentView.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 24/03/25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(Settings.self) private var settings

    /// Não remover esses `@Query`, por algum motivo
    /// eles evitam o app de travar ao deletar algum
    /// item dos modelos.
    @Query private var subjects: [Subject]
    @Query private var todos: [ToDo]
    @Query private var study: [SRStudy]

    // MARK: - Views

    var body: some View {
        TabView {
            Tab("Subjects", systemImage: "book.fill") {
                SubjectsView()
                    .toolbarBackground(.visible, for: .tabBar)
                    .toolbarBackground(Color.orhadiBG, for: .tabBar)
            }
            Tab("To-Dos", systemImage: "list.bullet.clipboard.fill") {
                ToDosView()
                    .toolbarBackground(.visible, for: .tabBar)
                    .toolbarBackground(Color.orhadiBG, for: .tabBar)
            }
            Tab("Studies", systemImage: "graduationcap.fill") {
                SRView()
                    .toolbarBackground(.visible, for: .tabBar)
                    .toolbarBackground(Color.orhadiBG, for: .tabBar)
            }
            Tab("Settings", systemImage: "gearshape.fill") {
                SettingsView(settings: settings)
                    .toolbarBackground(.visible, for: .tabBar)
                    .toolbarBackground(Color.orhadiBG, for: .tabBar)
            }
        }
        .preferredColorScheme(getTheme(for: settings.theme))
    }

    func getTheme(for theme: Theme) -> ColorScheme? {
        switch theme {
        case .auto: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(SampleData.shared.container)
        .environment(Settings())
}
