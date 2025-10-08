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
        if #available(iOS 26, *) {
            TabView {
                Tab("Subjects", systemImage: "book.fill") {
                    SubjectsView()
                }
                Tab("To-Dos", systemImage: "list.bullet.clipboard.fill") {
                    ToDosView()
                }
                Tab("Studies", systemImage: "graduationcap.fill") {
                    SRView()
                }
                Tab("Settings", systemImage: "gearshape.fill") {
                    SettingsView(settings: settings)
                }
            }
            .tabBarMinimizeBehavior(.onScrollDown)
            .preferredColorScheme(getTheme(for: settings.theme))
        } else {
            TabView {
                Tab("Subjects", systemImage: "book.fill") {
                    SubjectsView()
                }
                Tab("To-Dos", systemImage: "list.bullet.clipboard.fill") {
                    ToDosView()
                }
                Tab("Studies", systemImage: "graduationcap.fill") {
                    SRView()
                }
                Tab("Settings", systemImage: "gearshape.fill") {
                    SettingsView(settings: settings)
                }
            }
            .preferredColorScheme(getTheme(for: settings.theme))
        }
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
