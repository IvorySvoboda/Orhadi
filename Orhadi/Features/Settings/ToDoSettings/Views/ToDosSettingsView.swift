//
//  TasksSettingsView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 01/04/25.
//

import SwiftUI
import SwiftData

struct ToDosSettingsView: View {
    @State private var vm = ViewModel(dataManager: .shared)

    // MARK: - Views

    var body: some View {
        Form {
            Section {
                Toggle(
                    "Schedule Notifications",
                    isOn: $vm.settings.scheduleNotifications
                )
                .disabled(!vm.notificationStatus)
                .onChange(of: vm.settings.scheduleNotifications) { _, _ in
                    vm.save()
                }
            } header: {
                Text("Notifications")
            } footer: {
                Text(
                    "When activated, notifications will be scheduled to remind you of to-dos approaching their deadlines. Disabling this option will not cancel already scheduled notifications."
                )
            }

            if !vm.archivedTodos.isEmpty {
                Section {
                    NavigationLink {
                        ArchivedTodosView()
                    } label: {
                        Text("Archived To-Dos")
                    }
                }
            }

            if !vm.deletedTodos.isEmpty {
                Section {
                    NavigationLink {
                        DeletedTodosView()
                    } label: {
                        Text("Deleted To-Dos")
                    }
                }
            }
        }
        .navigationTitle("To-Dos")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            NotificationsManager.shared.notificationStatus { authorizedStatus in
                vm.notificationStatus = authorizedStatus
                if !vm.notificationStatus {
                    vm.settings.scheduleNotifications = false
                }
            }
        }
    }
}
