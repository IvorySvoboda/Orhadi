//
//  OrhadiApp.swift
//  Orhadi
//
//  Created by Zyvoxi . on 24/03/25.
//

import SwiftData
import SwiftUI
import UserNotifications

@main
struct OrhadiApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Subject.self,
            SRSubject.self,
            ToDo.self,
            Settings.self,
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema, isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema, configurations: [modelConfiguration]
            )
        } catch {
            fatalError(
                "Could not create ModelContainer: \(error.localizedDescription)"
            )
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [Settings]

    var body: some View {
        ContentView()
            .onAppear {
                if settings.first == nil {
                    modelContext.insert(Settings())
                }
                NotificationsManager.shared.requestNotificationAuthorization()
            }
            .environment(settings.first ?? Settings())
    }
}
