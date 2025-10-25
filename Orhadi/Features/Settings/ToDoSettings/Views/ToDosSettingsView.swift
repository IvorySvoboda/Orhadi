//
//  TasksSettingsView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 01/04/25.
//

import SwiftUI
import SwiftData

struct ToDosSettingsView: View {
    @Query private var todos: [ToDo]
    @Environment(\.modelContext) private var context
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
                    "Schedule Notifications",
                    isOn: $settings.scheduleNotifications
                )
                .disabled(!notificationStatus)
                .onChange(of: settings.scheduleNotifications) { _, _ in
                    do {
                        try context.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            } header: {
                Text("Notifications")
            } footer: {
                Text(
                    "When activated, notifications will be scheduled to remind you of to-dos approaching their deadlines. Disabling this option will not cancel already scheduled notifications."
                )
            }

            if !archivedTodos.isEmpty {
                Section {
                    NavigationLink {
                        ArchivedTodosView()
                    } label: {
                        Text("Archived To-Dos")
                    }
                }
            }

            if !deletedTodos.isEmpty {
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
                self.notificationStatus = authorizedStatus
                if !notificationStatus {
                    settings.scheduleNotifications = false
                }
            }
        }
    }
}
