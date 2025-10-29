//
//  SubjectsSettingsViewModel.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 29/10/25.
//

import Foundation
import Observation
import Combine

extension SubjectsSettingsView {
    @Observable class ViewModel {
        // MARK: - Properties

        private let dataManager: DataManager
        private var cancellable: AnyCancellable?
        var settings: Settings
        var deletedSubjects: [Subject] = []

        // MARK: - INIT

        init(dataManager: DataManager) {
            self.dataManager = dataManager
            self.settings = dataManager.settings
            setup()
        }

        // MARK: - Functions

        private func setup() {
            cancellable = dataManager.observeContextChanges(of: Subject.self) { [weak self] in
                self?.updateSubjects()
            }
            updateSubjects()
        }

        private func updateSubjects() {
            deletedSubjects = dataManager.fetchSubjects(
                predicate: #Predicate { $0.isSubjectDeleted }
            )
        }

        func save() {
            try? dataManager.save()
        }
    }
}
