//
//  TasksSettingsView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 01/04/25.
//

import SwiftUI
import SwiftData

struct ToDosSettingsView: View {
    @State private var viewModel = ViewModel(dataManager: .shared)

    // MARK: - Views

    var body: some View {
        Form {
            Section {
                Toggle(
                    "Schedule Notifications",
                    isOn: $viewModel.settings.scheduleNotifications
                )
                .disabled(!viewModel.notificationStatus)
                .onChange(of: viewModel.settings.scheduleNotifications) { _, _ in
                    viewModel.save()
                }
            } header: {
                Text("Notifications")
            } footer: {
                Text(
                    "When activated, notifications will be scheduled to remind you of to-dos approaching their deadlines. Disabling this option will not cancel already scheduled notifications."
                )
            }

            if !viewModel.archivedTodos.isEmpty {
                Section {
                    NavigationLink {
                        ArchivedTodosView()
                    } label: {
                        Text("Archived To-Dos")
                    }
                }
            }

            if !viewModel.deletedTodos.isEmpty {
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
                viewModel.notificationStatus = authorizedStatus
                if !viewModel.notificationStatus {
                    viewModel.settings.scheduleNotifications = false
                }
            }
        }
    }
}
