//
//  TasksSettingsView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 01/04/25.
//

import SwiftUI

struct ToDosSettingsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(OrhadiTheme.self) private var theme

    @State private var notificationStatus: Bool = false

    @Bindable var settings: Settings

    var body: some View {
        Form {
            Section {
                Toggle(
                    "Confirmar para Excluir",
                    isOn: $settings.todosDeleteConfirmation
                )

                ToDoGracePeriodePickerView()
            }.listRowBackground(theme.secondaryBGColor())

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
            .listRowBackground(theme.secondaryBGColor())
        }
        .modifier(DefaultList())
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

struct ToDoGracePeriodePickerView: View {
    @Environment(Settings.self) private var settings

    var body: some View {
        NavigationLink {
            ToDoGracePeriodePicker()
        } label: {
            HStack {
                Text("Tolerância")
                Spacer()
                Text(formatTimeInterval(settings.gracePeriod))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct ToDoGracePeriodePicker: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @Environment(Settings.self) private var settings
    @Environment(OrhadiTheme.self) private var theme

    var body: some View {
        List {
            Section {
                ForEach(1..<5) { i in
                    Button {
                        settings.gracePeriod = TimeInterval(21600 * i)
                        dismiss()
                    } label: {
                        HStack {
                            Text(formatTimeInterval(TimeInterval(21600 * i)))
                            Spacer()
                            if settings.gracePeriod == TimeInterval(21600 * i) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }.tint(colorScheme == .dark ? .white : .black)
                }
            }.listRowBackground(theme.secondaryBGColor())

            Section {
                Button {
                    settings.gracePeriod = 0
                    dismiss()
                } label: {
                    HStack {
                        Text("Sem Tolerância")
                            .foregroundStyle(.secondary)
                        Spacer()
                        if settings.gracePeriod == 0 {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }.tint(Color.secondary)
            }.listRowBackground(theme.secondaryBGColor())
        }
        .modifier(DefaultList())
        .navigationTitle("Tolerância")
        .navigationBarTitleDisplayMode(.inline)
    }
}
