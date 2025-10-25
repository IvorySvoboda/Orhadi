//
//  ContentView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 24/03/25.
//

import SwiftData
import SwiftUI
import WidgetKit

struct ContentView: View {
    @Environment(Settings.self) private var settings

    // MARK: - Views

    var body: some View {
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
        .backport.tabBarMinimizeBehavior(.onScrollDown)
        .preferredColorScheme(getTheme(for: settings.theme))
        .onReceive(NotificationCenter.default.publisher(for: ModelContext.didSave)) { _ in
            WidgetCenter.shared.reloadAllTimelines()
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
