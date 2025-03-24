//
//  TasksSettingsView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 01/04/25.
//

import SwiftUI

struct ToDosSettingsView: View {
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

            Section {
                Toggle(
                    "Agendar Notificações",
                    isOn: $settings.scheduleNotifications
                ).tint(.green).disabled(notificationStatus)
            } header: {
                Text("Notificações")
            } footer: {
                Text(
                    "Quando ativado, notificações serão agendadas para lembrar você de tarefas próximas ao prazo final. Desativar essa opção não cancelará notificações já agendadas."
                )
            }
        }
        .navigationTitle("Tarefas")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                notificationStatus = await NotificationsManager.shared.notificationStatus()
            }
        }
    }
}

