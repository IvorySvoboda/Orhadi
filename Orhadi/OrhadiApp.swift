//
//  OrhadiApp.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 24/03/25.
//

import SwiftData
import SwiftUI
import WidgetKit

@main
struct OrhadiApp: App {
    /// Cria o container do SwiftData
    var container: ModelContainer {
        do {
            return try createContainer()
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }.modelContainer(container)
    }
}

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [Settings]

    var body: some View {
        ContentView()
            .onAppear {
                /// Verifica se `settings` é nil, se for, insere ele no context.
                if settings.first == nil {
                    modelContext.insert(Settings())
                }

                /// Solicita permissão para as notificações
                NotificationsManager.shared.requestNotificationAuthorization()

                /// Apagas itens apagados a mais de 30 dias
                cleanOldDeleted()

                WidgetCenter.shared.reloadAllTimelines()
            }
            .environment(settings.first ?? Settings())
    }
}
