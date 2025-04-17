//
//  OrhadiApp.swift
//  Orhadi
//
//  Created by Zyvoxi . on 24/03/25.
//

import SwiftData
import SwiftUI
import UserNotifications

typealias Subject = OrhadiSchemaV3.Subject
typealias SRSubject = OrhadiSchemaV3.SRSubject
typealias ToDo = OrhadiSchemaV3.ToDo
typealias Settings = OrhadiSchemaV3.Settings
typealias Teacher = OrhadiSchemaV3.Teacher
typealias UserProfile = OrhadiSchemaV3.UserProfile
typealias Achievement = OrhadiSchemaV3.Achievement

@main
struct OrhadiApp: App {
    var sharedModelContainer: ModelContainer = {
        do {
            let databasePath = URL.documentsDirectory.appending(path: "database.store")

            let configuration = ModelConfiguration(url: databasePath)

            let container = try ModelContainer.init(
                for: Schema(versionedSchema: OrhadiSchemaV3.self),
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
    @Query private var userProfile: [UserProfile]

    var body: some View {
        ContentView()
            .onAppear {
                if settings.first == nil {
                    modelContext.insert(Settings())
                }
                if userProfile.first == nil {
                    modelContext.insert(UserProfile())
                }
                NotificationsManager.shared.requestNotificationAuthorization()
            }
            .environment(settings.first ?? Settings())
            .environment(userProfile.first ?? UserProfile())
            .environment(GameManager(context: modelContext))
    }
}
