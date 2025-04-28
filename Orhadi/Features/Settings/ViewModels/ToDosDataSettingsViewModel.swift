//
//  ToDosDataSettingsViewModel.swift
//  Orhadi
//
//  Created by Zyvoxi . on 28/04/25.
//

import SwiftUI
import SwiftData
import Observation

@Observable class ToDosDataSettingsViewModel {
    // MARK: -Properties

    var showDeleteConfirmation: Bool = false

    /// Exporter
    var todosExportItem: ToDoTransferable?
    var showToDosFileExporter: Bool = false

    /// Importer
    var showToDosImportAlert: Bool = false
    var showToDosFileImporter: Bool = false
    var importedURL: URL?

    // MARK: - Computed Properties

    var todos: [ToDo]? {
        let context = try! createContext()
        return try? context.fetch(FetchDescriptor<ToDo>())
    }

    var completedTodos: Int {
        (todos?.filter({ $0.isCompleted }) ?? []).count
    }

    var pendingTodos: Int {
        (todos?.filter({ $0.dueDate > .now && !$0.isCompleted }) ?? []).count
    }

    var overdueTodos: Int {
        (todos?.filter({ $0.dueDate < .now && !$0.isCompleted }) ?? []).count
    }

    // MARK: - Actions

    func deleteAllToDo() {
        Task.detached(priority: .background) {
            do {
                let context = try createContext()

                let todos = try context.fetch(FetchDescriptor<ToDo>())

                for todo in todos {
                    let todoID = todo.id
                    let identifiers = [
                        "\(todoID)-1h",
                        "\(todoID)-24h",
                        "\(todoID)-due",
                    ]

                    NotificationsManager.shared.removePendingNotifications(withIdentifiers: identifiers)

                    context.delete(todo)
                }

                try context.save()

                await UINotificationFeedbackGenerator().notificationOccurred(.success)
            } catch {
                print(error.localizedDescription)
                await UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }

    func exportToDos() {
        Task.detached(priority: .background) {
            do {
                let context = try createContext()

                let descriptor = FetchDescriptor(sortBy: [SortDescriptor(\ToDo.dueDate, order: .forward)])

                let allObjects = try context.fetch(descriptor)
                let exportItem = ToDoTransferable(todos: allObjects)

                await UINotificationFeedbackGenerator().notificationOccurred(.success)

                await MainActor.run {
                    self.todosExportItem = exportItem
                    self.showToDosFileExporter = true
                }
            } catch {
                print(error.localizedDescription)
                await UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }

    func importToDos() {
        guard let url = importedURL else { return }
        Task.detached(priority: .background) {
            do {
                guard url.startAccessingSecurityScopedResource() else { return }

                let context = try createContext()

                let existingToDos = try context.fetch(FetchDescriptor<ToDo>())

                for todo in existingToDos {
                    let todoID = todo.id
                    let identifiers = [
                        "\(todoID)-1h",
                        "\(todoID)-24h",
                        "\(todoID)-due",
                    ]

                    NotificationsManager.shared.removePendingNotifications(withIdentifiers: identifiers)

                    context.delete(todo)
                }

                let data = try Data(contentsOf: url)
                let allToDos = try JSONDecoder().decode(
                    [ToDo].self, from: data)

                for todo in allToDos {
                    if !todo.isCompleted, todo.dueDate > Date() {
                        todo.scheduleNotification()
                    }
                    context.insert(todo)
                }

                try context.save()

                url.stopAccessingSecurityScopedResource()

                await UINotificationFeedbackGenerator().notificationOccurred(.success)
            } catch {
                print(error.localizedDescription)
                await UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }
}

