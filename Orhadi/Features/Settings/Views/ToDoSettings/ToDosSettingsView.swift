//
//  TasksSettingsView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 01/04/25.
//

import SwiftUI
import SwiftData

struct ToDosSettingsView: View {

    @Query private var todos: [ToDo]

    @State private var notificationStatus: Bool = false

    @Bindable var settings: Settings

    var deletedTodos: [ToDo] {
        todos.filter {
            $0.isToDoDeleted
        }
    }

    var archivedTodos: [ToDo] {
        todos.filter {
            $0.isArchived && !$0.isToDoDeleted
        }
    }

    var body: some View {
        Form {
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
            .orhadiListRowBackground()

            if !archivedTodos.isEmpty {
                Section {
                    NavigationLink {
                        ArchivedTodosView()
                    } label: {
                        Text("Tarefas Arquivadas")
                    }
                }.orhadiListRowBackground()
            }

            if !deletedTodos.isEmpty {
                Section {
                    NavigationLink {
                        DeletedTodosView()
                    } label: {
                        Text("Tarefas Apagadas")
                    }
                }.orhadiListRowBackground()
            }
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
