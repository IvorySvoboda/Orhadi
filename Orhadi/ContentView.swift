//
//  ContentView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 24/03/25.
//

import SwiftData
import SwiftUI

enum Theme: Codable, CaseIterable {
    case light, dark, auto

    var name: String {
        switch self {
        case .light:
            return String(localized: "Claro")
        case .dark:
            return String(localized: "Escuro")
        case .auto:
            return String(localized: "Auto")
        }
    }
}

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(Settings.self) private var settings

    var body: some View {
        TabView {
            Tab("Matérias", systemImage: "book.fill") {
                SubjectsView()
                    .toolbarBackground(Color.orhadiBG, for: .tabBar)
            }
            Tab("Tarefas", systemImage: "list.bullet.clipboard.fill") {
                ToDosView()
                    .toolbarBackground(Color.orhadiBG, for: .tabBar)
            }
            Tab("Rotina de Estudos", systemImage: "graduationcap.fill") {
                SRView()
                    .toolbarBackground(Color.orhadiBG, for: .tabBar)
            }
            Tab("Ajustes", systemImage: "gearshape.fill") {
                SettingsView(settings: settings)
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
