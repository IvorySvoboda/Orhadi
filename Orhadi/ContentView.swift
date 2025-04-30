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

    // MARK: - Queries

    /// Esses `Query`aqui não tem utilidades, mas
    /// por algum motivo, ele evitam o view `ToDoView`
    /// de "crashar" ao completar/descompletar ou
    /// deletar uma tarefa, e não, não adianta tentar
    /// passar esse query para o `ToDoView` porque ela
    /// vai continuar "crashando".
    @Query private var _todos: [ToDo]
    /// esses queries estão aqui também por conta do
    /// mesmo motivo, só que apenas na parte de deletar…
    @Query private var _subjects: [Subject]
    @Query private var _studies: [SRStudy]

    // MARK: - Views

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
