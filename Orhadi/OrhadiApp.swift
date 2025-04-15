//
//  OrhadiApp.swift
//  Orhadi
//
//  Created by Zyvoxi . on 24/03/25.
//

import SwiftData
import SwiftUI
import UserNotifications

typealias Subject = OrhadiSchemaV2.Subject
typealias SRSubject = OrhadiSchemaV2.SRSubject
typealias ToDo = OrhadiSchemaV2.ToDo
typealias Settings = OrhadiSchemaV2.Settings
typealias Teacher = OrhadiSchemaV2.Teacher

@main
struct OrhadiApp: App {
    var sharedModelContainer: ModelContainer = {
        do {
            let databasePath = URL.documentsDirectory.appending(path: "database.store")

            let configuration = ModelConfiguration(url: databasePath)

            let container = try ModelContainer.init(
                for: Subject.self, SRSubject.self, ToDo.self, Settings.self, Teacher.self,
                migrationPlan: MigrationPlan.self,
                configurations: configuration
            )

            return container
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
