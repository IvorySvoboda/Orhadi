//
//  OrhadiApp.swift
//  Orhadi
//
//  Created by Zyvoxi . on 24/03/25.
//

import SwiftData
import SwiftUI
import UserNotifications

typealias CurrentSchema = OrhadiSchemaV1
typealias Subject = CurrentSchema.Subject
typealias SRStudy = CurrentSchema.SRStudy
typealias ToDo = CurrentSchema.ToDo
typealias Settings = CurrentSchema.Settings
typealias Teacher = CurrentSchema.Teacher
typealias UserProfile = CurrentSchema.UserProfile
typealias Achievement = CurrentSchema.Achievement

@main
struct OrhadiApp: App {
    /// Crie o container do SwiftData
    let container = try! createContainer()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [Settings]
    @Query private var userProfile: [UserProfile]

    var body: some View {
        ContentView()
            .onAppear {
                /// Verifica se `settings` e `userProfile` é nil, se for, insere eles no context.
                if settings.first == nil {
                    modelContext.insert(Settings())
                }
                if userProfile.first == nil {
                    modelContext.insert(UserProfile())
                }
                /// Solicita permissão para as notificações
                NotificationsManager.shared.requestNotificationAuthorization()
            }
            /// Coloca no Environment algumas variáveis uteis
            .environment(settings.first ?? Settings())
            .environment(userProfile.first ?? UserProfile())
            .environment(GameManager(context: modelContext))
    }
}
