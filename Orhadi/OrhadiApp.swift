//
//  OrhadiApp.swift
//  Orhadi
//
//  Created by Zyvoxi . on 24/03/25.
//

import SwiftData
import SwiftUI
import UserNotifications

typealias Subject = SubjectSchemaV1.Subject
typealias SRSubject = SRSubjectSchemaV1.SRSubject
typealias ToDo = ToDoSchemaV1.ToDo
typealias Settings = SettingsSchemaV2.Settings

@main
struct OrhadiApp: App {
    var sharedModelContainer: ModelContainer = {
        do {
            let databasePath = URL.documentsDirectory.appending(path: "database.store")

            let configuration = ModelConfiguration(url: databasePath)

            let container = try ModelContainer.init(
                for: Subject.self, SRSubject.self, ToDo.self, Settings.self,
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
