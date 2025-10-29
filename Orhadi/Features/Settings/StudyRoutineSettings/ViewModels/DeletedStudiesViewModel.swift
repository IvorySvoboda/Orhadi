//
//  DeletedStudyViewModel.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 23/10/25.
//

import Observation
import Combine
import SwiftUI

extension DeletedStudiesView {
    @Observable class ViewModel {
        // MARK: - Properties

        private let dataManager: DataManager
        private var cancellable: AnyCancellable?
        var deletedStudies: [SRStudy] = []
        var selectedStudies = Set<SRStudy>()
        var showDeleteConfirmation = false

        // MARK: - Computed Properties

        var countToActOn: Int {
            selectedStudies.isEmpty ? deletedStudies.count : selectedStudies.count
        }

        var isPlural: Bool {
            countToActOn > 1
        }

        var deleteActionTitle: LocalizedStringKey {
            if isPlural {
                return "Delete \(countToActOn) Studies"
            } else {
                return "Delete Study"
            }
        }

        var deleteMessageText: LocalizedStringKey {
            if isPlural {
                return
                    "These \(countToActOn) studies will be deleted. This action cannot be undone."
            } else {
                return
                    "This study will be deleted. This action cannot be undone."
            }
        }

        // MARK: - INIT

        init(dataManager: DataManager) {
            self.dataManager = dataManager
            setup()
        }

        // MARK: - Functinos

        private func setup() {
            cancellable = dataManager.observeContextChanges(of: SRStudy.self) { [weak self] in
                self?.updateStudies()
            }
            updateStudies()
        }

        private func updateStudies() {
            deletedStudies = dataManager.fetchStudies(
                predicate: #Predicate { $0.isStudyDeleted },
                sortBy: [.init(\.deletedAt)]
            )
        }

        func hardDeleteStudy(_ study: SRStudy) throws {
            try dataManager.hardDeleteStudy(study)
        }

        func restoreStudy(_ study: SRStudy) throws {
            try dataManager.restoreStudy(study)
        }

        func deleteStudies() {
            if selectedStudies.isEmpty {
                for study in deletedStudies {
                    try? hardDeleteStudy(study)
                }
            } else {
                for study in selectedStudies {
                    try? hardDeleteStudy(study)
                }
                selectedStudies.removeAll()
            }
        }

        func restoreStudies() {
            if selectedStudies.isEmpty {
                for study in deletedStudies {
                    try? restoreStudy(study)
                }
            } else {
                for study in selectedStudies {
                    try? restoreStudy(study)
                }
                selectedStudies.removeAll()
            }
        }
    }
}
