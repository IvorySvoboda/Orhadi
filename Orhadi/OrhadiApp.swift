//
//  OrhadiApp.swift
//  Orhadi
//
//  Created by Zyvoxi . on 24/03/25.
//

import SwiftData
import SwiftUI
import UserNotifications

typealias CurrentSchema = OrhadiSchemaV3
typealias Subject = CurrentSchema.Subject
typealias SRSubject = CurrentSchema.SRSubject
typealias ToDo = CurrentSchema.ToDo
typealias Settings = CurrentSchema.Settings
typealias Teacher = CurrentSchema.Teacher
typealias UserProfile = CurrentSchema.UserProfile
typealias Achievement = CurrentSchema.Achievement

@main
struct OrhadiApp: App {
    let container = try! ModelContainer.init(
        for: Schema(versionedSchema: CurrentSchema.self),
        migrationPlan: MigrationPlan.self,
        configurations: ModelConfiguration(url: URL.documentsDirectory.appending(path: "database.store"))
    )

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}

struct RootView: View {
    @Environment(\.colorScheme) private var scheme
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
            .environment(OrhadiTheme(colorScheme: scheme))
    }
}
