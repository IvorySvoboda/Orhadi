//
//  TasksSettingsView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 01/04/25.
//

import SwiftUI

struct ToDosSettingsView: View {
    @Environment(\.colorScheme) private var colorScheme

    @State private var notificationStatus: Bool = false

    @Bindable var settings: Settings

    var body: some View {
        Form {
            Section {
                Toggle(
                    "Confirmar para Excluir",
                    isOn: $settings.todosDeleteConfirmation
                )
            }.listRowBackground(Color.orhadiSecondaryBG)

            Section {
                Toggle(
                    "Agendar Notificações",
                    isOn: $settings.scheduleNotifications
                ).disabled(!notificationStatus)
            } header: {
                Text("Notificações")
            } footer: {
                Text(
                    "Quando ativado, notificações serão agendadas para lembrar você de tarefas próximas ao prazo final. Desativar essa opção não cancelará notificações já agendadas."
                )
            }
            .listRowBackground(Color.orhadiSecondaryBG)
        }
        .orhadiListStyle()
        .navigationTitle("Tarefas")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            NotificationsManager.shared.notificationStatus { authorizedStatus in
                self.notificationStatus = authorizedStatus
                if !notificationStatus {
                    settings.scheduleNotifications = false
                }
            }
        }
    }
}
