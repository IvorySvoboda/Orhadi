//
//  DeletedTodosViewModel.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 23/10/25.
//

import SwiftUI
import Observation
import Combine

extension DeletedTodosView {
    @Observable class ViewModel {
        // MARK: - Properties

        private let dataManager: DataManager
        private var cancellable: AnyCancellable?
        var deletedToDos: [ToDo] = []
        var selectedToDos = Set<ToDo>()
        var showDeleteConfirmation = false

        // MARK: - Computed Properties

        var countToActOn: Int {
            selectedToDos.isEmpty ? deletedToDos.count : selectedToDos.count
        }

        var isPlural: Bool {
            countToActOn > 1
        }

        var deleteActionTitle: LocalizedStringKey {
            if isPlural {
                return "Delete \(countToActOn) To-Dos"
            } else {
                return "Delete To-Do"
            }
        }

        var deleteMessageText: LocalizedStringKey {
            if isPlural {
                return "These \(countToActOn) to-dos will be deleted. This action cannot be undone."
            } else {
                return "This to-do will be deleted. This action cannot be undone."
            }
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
            deletedToDos = dataManager.fetchToDos(
                predicate: #Predicate { $0.isToDoDeleted },
                sortBy: [.init(\.deletedAt)]
            )
        }

        func hardDeleteToDo(_ todo: ToDo) throws {
            try dataManager.hardDeleteToDo(todo)
        }

        func restoreToDo(_ todo: ToDo) throws {
            try dataManager.restoreToDo(todo)
        }

        func deleteToDos() {
            if selectedToDos.isEmpty {
                for todo in deletedToDos {
                    try? hardDeleteToDo(todo)
                }
            } else {
                for todo in selectedToDos {
                    try? hardDeleteToDo(todo)
                }
                selectedToDos.removeAll()
            }
        }

        func restoreToDos() {
            if selectedToDos.isEmpty {
                for todo in deletedToDos {
                    try? restoreToDo(todo)
                }
            } else {
                for todo in selectedToDos {
                    try? restoreToDo(todo)
                }
                selectedToDos.removeAll()
            }
        }
    }
}
