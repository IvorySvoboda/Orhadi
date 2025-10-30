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
                SettingsView()
            }
        }
        .backport.tabBarMinimizeBehavior(.onScrollDown)
        .preferredColorScheme(DataManager.shared.settings.theme.colorScheme)
        .onAppear {
            /// Solicita permissão para as notificações
            NotificationsManager.shared.requestNotificationAuthorization()
        }
        .environment(DataManager.shared.settings)
        .onReceive(NotificationCenter.default.publisher(for: ModelContext.didSave)) { _ in
            WidgetCenter.shared.reloadAllTimelines() /// Reload all Widgets timelines when context saves.
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(DataManager.shared.container)
        .environment(Settings())
}
