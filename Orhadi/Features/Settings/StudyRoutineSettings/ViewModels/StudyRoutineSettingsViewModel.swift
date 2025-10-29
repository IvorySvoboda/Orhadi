//
//  StudyRoutineSettingsViewModel.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 29/10/25.
//

import Foundation
import Combine
import Observation

extension StudyRoutineSettingsView {
    @Observable class ViewModel {
        // MARK: - Properties

        private let dataManager: DataManager
        private var cancellable: AnyCancellable?
        var settings: Settings
        var deletedStudies: [SRStudy] = []

        // MARK: - INIT

        init(dataManager: DataManager) {
            self.dataManager = dataManager
            self.settings = dataManager.settings
            setup()
        }

        // MARK: - Functions

        private func setup() {
            cancellable = dataManager.observeContextChanges(of: SRStudy.self) { [weak self] in
                self?.updateStudies()
            }
            updateStudies()
        }

        private func updateStudies() {
            deletedStudies = dataManager.fetchStudies(
                predicate: #Predicate { $0.isStudyDeleted }
            )
        }

        func save() {
            try? dataManager.save()
        }
    }
}
