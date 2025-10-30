//
//  ToDosDataSettingsViewModel.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 23/10/25.
//

import SwiftUI
import SwiftData
import Observation
import Combine

extension ToDosDataSettingsView {
    @Observable class ViewModel {
        // MARK: - Properties

        private let dataManager: DataManager
        private var cancellable: AnyCancellable?
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

        // MARK: - Computed Properties

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

        // MARK: - INIT

        init(dataManager: DataManager) {
            self.dataManager = dataManager
            setup()
        }

        // MARK: - Functions

        private func setup() {
            cancellable = dataManager.observeContextChanges(of: ToDo.self) { [weak self] in
                self?.updateToDos()
            }
            updateToDos()
        }

        private func updateToDos() {
            todos = dataManager.fetchToDos(
                predicate: #Predicate { !$0.isToDoDeleted }
            )
        }

        func deleteAllToDos() throws {
            do {
                let context = ModelContext(dataManager.container)

                let todos = try context.fetch(FetchDescriptor<ToDo>(predicate: #Predicate {
                    !$0.isToDoDeleted
                }))

                for todo in todos {
                    NotificationsManager.shared.removePendingNotifications(withIdentifiers: todo.identifiers)

                    todo.isToDoDeleted = true
                    todo.deletedAt = .now
                }

                try context.save()

                FeedbackGenerator().notificationOccurred(.success)
            } catch {
                errorMessage = error.localizedDescription
                showErrorMessage.toggle()
                FeedbackGenerator().notificationOccurred(.error)
                throw error /// Useful for unit tests.
            }
        }

        func exportToDos() throws {
            do {
                let context = ModelContext(dataManager.container)

                let descriptor = FetchDescriptor(predicate: #Predicate<ToDo> {
                    !$0.isToDoDeleted
                })

                let allObjects = try context.fetch(descriptor)
                let data = try JSONEncoder().encode(allObjects)
                let exportItem = DataTransferable(data: data)

                todosExportItem = exportItem
                showToDosFileExporter = true

                FeedbackGenerator().notificationOccurred(.success)
            } catch {
                errorMessage = error.localizedDescription
                showErrorMessage.toggle()
                FeedbackGenerator().notificationOccurred(.error)
                throw error /// Useful for unit tests.
            }
        }

        func importToDos() throws {
            guard let url = importedURL else { return }
            let isInBundle = url.path.contains(Bundle.main.bundlePath)
            guard url.startAccessingSecurityScopedResource() || isInBundle else { return }
            defer { if !isInBundle { url.stopAccessingSecurityScopedResource() } }
            do {
                let context = ModelContext(dataManager.container)

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
                        /// Restaura a tarefa do lixo
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

                FeedbackGenerator().notificationOccurred(.success)
            } catch {
                errorMessage = error.localizedDescription
                showErrorMessage.toggle()
                FeedbackGenerator().notificationOccurred(.error)
                throw error /// Useful for unit tests.
            }
        }
    }
}
