//
//  ToDosSettingsViewModel.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 29/10/25.
//

import Foundation
import Combine
import Observation

extension ToDosSettingsView {
    @Observable class ViewModel {
        // MARK: - Properties

        private let dataManager: DataManager
        private var cancellable: AnyCancellable?
        var settings: Settings
        var notificationStatus: Bool = false
        var deletedTodos: [ToDo] = []
        var archivedTodos: [ToDo] = []

        // MARK: - INIT

        init(dataManager: DataManager) {
            self.dataManager = dataManager
            self.settings = dataManager.settings
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
            deletedTodos = dataManager.fetchToDos(
                predicate: #Predicate { $0.isToDoDeleted }
            )
            archivedTodos = dataManager.fetchToDos(
                predicate: #Predicate { !$0.isToDoDeleted && $0.isArchived }
            )
        }

        func save() {
            try? dataManager.save()
        }
    }
}
