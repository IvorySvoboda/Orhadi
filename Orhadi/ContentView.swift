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
    @Environment(\.modelContext) private var context
    @Environment(Settings.self) private var settings

    // MARK: - Views

    var body: some View {
        TabView {
            Tab("Subjects", systemImage: "book.fill") {
                SubjectsView(context: context)
            }
            Tab("To-Dos", systemImage: "list.bullet.clipboard.fill") {
                ToDosView(context: context)
            }
            Tab("Studies", systemImage: "graduationcap.fill") {
                SRView(context: context)
            }
            Tab("Settings", systemImage: "gearshape.fill") {
                SettingsView(settings: settings)
            }
        }
        .backport.tabBarMinimizeBehavior(.onScrollDown)
        .preferredColorScheme(getTheme(for: settings.theme))
        .onReceive(NotificationCenter.default.publisher(for: ModelContext.didSave)) { _ in
            WidgetCenter.shared.reloadAllTimelines() /// Reload all Widgets timelines when context saves.
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
        .modelContainer(PreviewHelper.shared.container)
        .environment(Settings())
}
