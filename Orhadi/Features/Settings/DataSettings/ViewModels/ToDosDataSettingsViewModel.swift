//
//  ToDosDataSettingsViewModel.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 23/10/25.
//

import UIKit
import SwiftData
import Observation

extension ToDosDataSettingsView {
    @Observable class ViewModel {
        var container: ModelContainer
        var onCompletion: (() -> Void)?
        var context: ModelContext?
        var todos: [ToDo] = []
        var showDeleteConfirmation: Bool = false
        var showErrorMessage: Bool = false
        var errorMessage: String = ""
        /// Exporter
        var todosExportItem: DataTransferable?
        var showToDosFileExporter: Bool = false
        /// Importer
        var showToDosImportAlert: Bool = false
        var showToDosFileImporter: Bool = false
        var importedURL: URL?

        var completedTodos: Int {
            todos.filter({ $0.isCompleted && !$0.isArchived }).count
        }

        var pendingTodos: Int {
            todos.filter({ $0.dueDate > .now && !$0.isCompleted && !$0.isArchived }).count
        }

        var overdueTodos: Int {
            todos.filter({ $0.dueDate < .now && !$0.isCompleted && !$0.isArchived }).count
        }

        var archivedTodos: Int {
            todos.filter({ !$0.isToDoDeleted && $0.isArchived }).count
        }

        init(container: ModelContainer = createContainer()) {
            self.container = container
        }

        func fetchToDos() {
            guard let context else { return }
            print("To-Dos Data Settings: fetching...")
            do {
                let descriptor = FetchDescriptor<ToDo>(predicate: #Predicate {
                    !$0.isToDoDeleted
                })
                todos = try context.fetch(descriptor)
            } catch {
                print(error.localizedDescription)
            }
        }

        func handleErrorMessageChange() {
            if !errorMessage.isEmpty {
                showErrorMessage = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.errorMessage = ""
                }
            }
        }

        func deleteAllToDo() {
            Task.detached(priority: .background) {
                defer { self.onCompletion?() }
                do {
                    let context = ModelContext(self.container)

                    let todos = try context.fetch(FetchDescriptor<ToDo>(predicate: #Predicate<ToDo> {
                        !$0.isToDoDeleted
                    }))

                    for todo in todos {
                        NotificationsManager.shared.removePendingNotifications(withIdentifiers: todo.identifiers)

                        todo.isToDoDeleted = true
                        todo.deletedAt = .now
                    }

                    try context.save()

                    await UINotificationFeedbackGenerator().notificationOccurred(.success)
                } catch {
                    await MainActor.run {
                        self.errorMessage = error.localizedDescription
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                    }
                }
            }
        }

        func exportToDos() {
            Task.detached(priority: .background) {
                defer { self.onCompletion?() }
                do {
                    let context = ModelContext(self.container)

                    let descriptor = FetchDescriptor(predicate: #Predicate<ToDo> {
                        !$0.isToDoDeleted
                    })

                    let allObjects = try context.fetch(descriptor)
                    let data = try JSONEncoder().encode(allObjects)
                    let exportItem = DataTransferable(data: data)

                    await UINotificationFeedbackGenerator().notificationOccurred(.success)

                    await MainActor.run {
                        self.todosExportItem = exportItem
                        self.showToDosFileExporter = true
                    }
                } catch {
                    await MainActor.run {
                        self.errorMessage = error.localizedDescription
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                    }
                }
            }
        }

        func importToDos() {
            guard let url = importedURL else { return }
            Task.detached(priority: .background) {
                guard url.startAccessingSecurityScopedResource() else { return }
                defer {
                    url.stopAccessingSecurityScopedResource()
                    self.onCompletion?()
                }
                do {
                    let context = ModelContext(self.container)

                    let data = try Data(contentsOf: url)
                    let importedTodos = try JSONDecoder().decode([ToDo].self, from: data)

                    var deletedToDos = try context.fetch(FetchDescriptor<ToDo>(predicate: #Predicate<ToDo> {
                        $0.isToDoDeleted
                    }))

                    let activeToDos = try context.fetch(FetchDescriptor<ToDo>(predicate: #Predicate<ToDo> {
                        !$0.isToDoDeleted
                    }))

                    /// Marcar All to-dos ativas como deletadas
                    for todo in activeToDos {
                        NotificationsManager.shared.removePendingNotifications(withIdentifiers: todo.identifiers)

                        todo.isToDoDeleted = true
                        todo.deletedAt = .now

                        deletedToDos.append(todo)
                    }

                    for imported in importedTodos {
                        /// Verificar se há uma tarefa no lixo com mesmo conteúdo
                        if let matchInTrash = deletedToDos.first(where: {
                            $0.title == imported.title &&
                            Calendar.current.isDate($0.dueDate, equalTo: imported.dueDate, toGranularity: .minute) &&
                            $0.info == imported.info
                        }) {
                            /// Restore a tarefa do lixo
                            matchInTrash.isToDoDeleted = false
                            matchInTrash.deletedAt = nil
                            matchInTrash.isCompleted = imported.isCompleted
                            if !matchInTrash.isCompleted, matchInTrash.dueDate > .now {
                                matchInTrash.scheduleNotification()
                            }
                        } else {
                            /// Nova tarefa
                            if !imported.isCompleted, imported.dueDate > .now {
                                imported.scheduleNotification()
                            }
                            context.insert(imported)
                        }
                    }

                    try context.save()

                    await MainActor.run {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }
                } catch {
                    await MainActor.run {
                        self.errorMessage = "\(error.localizedDescription)"
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                    }
                    print(error)
                }
            }
        }
    }
}
