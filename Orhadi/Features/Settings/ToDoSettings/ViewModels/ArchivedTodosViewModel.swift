//
//  ArchivedTodosViewModel.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 23/10/25.
//

import Foundation
import Observation
import Combine

extension ArchivedTodosView {
    @Observable class ViewModel {
        // MARK: - Properties

        private let dataManager: DataManager
        private var cancellable: AnyCancellable?
        var archivedToDos: [ToDo] = []
        var selectedToDos = Set<ToDo>()

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
            archivedToDos = dataManager.fetchToDos(
                predicate: #Predicate { !$0.isToDoDeleted && $0.isArchived },
                sortBy: [.init(\.title), .init(\.dueDate)]
            )
        }

        func unarchiveToDo(_ todo: ToDo) throws {
            try dataManager.unarchive(todo)
        }

        func softDeleteToDo(_ todo: ToDo) throws {
            try dataManager.softDelete(todo)
        }

        func deleteToDos() {
            if selectedToDos.isEmpty {
                for todo in archivedToDos {
                    try? softDeleteToDo(todo)
                }
            } else {
                for todo in selectedToDos {
                    try? softDeleteToDo(todo)
                }
                selectedToDos.removeAll()

            }
        }

        func unarchiveToDos() {
            if selectedToDos.isEmpty {
                for todo in archivedToDos {
                    try? unarchiveToDo(todo)
                }
            } else {
                for todo in selectedToDos {
                    try? unarchiveToDo(todo)
                }
                selectedToDos.removeAll()
            }
        }
    }
}
