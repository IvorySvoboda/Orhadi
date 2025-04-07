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
                .tint(.green)
                Toggle(
                    "Arraste para Excluir",
                    isOn: $settings.todosDeleteButton
                )
                .tint(.green)
            } header: {
                Text("Geral")
            }
            .listRowBackground(Color(red: 0.56, green: 0.56, blue: 0.56, opacity: 0.05))

            Section {
                Toggle(
                    "Agendar Notificações",
                    isOn: $settings.scheduleNotifications
                ).tint(.green).disabled(!notificationStatus)
            } header: {
                Text("Notificações")
            } footer: {
                Text(
                    "Quando ativado, notificações serão agendadas para lembrar você de tarefas próximas ao prazo final. Desativar essa opção não cancelará notificações já agendadas."
                )
            }
            .listRowBackground(Color(red: 0.56, green: 0.56, blue: 0.56, opacity: 0.05))
        }
        .background(OrhadiTheme.getBackgroundColor(for: colorScheme))
        .scrollContentBackground(.hidden)
        .navigationTitle("Tarefas")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(
            OrhadiTheme.getBackgroundColor(for: colorScheme),
            for: .navigationBar)
        .onAppear {
            NotificationsManager.shared.notificationStatus { authorizedStatus in
                notificationStatus = authorizedStatus
                if !notificationStatus {
                    settings.scheduleNotifications = false
                }
            }
        }
    }
}

