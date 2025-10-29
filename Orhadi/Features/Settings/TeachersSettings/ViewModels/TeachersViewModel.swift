//
//  TeachersViewModel.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 29/10/25.
//

import Foundation
import Observation
import Combine

extension TeachersView {
    @Observable class ViewModel {
        // MARK: - Properties

        private let dataManager: DataManager
        private var cancellable: AnyCancellable?
        var teachers: [Teacher] = []
        var teacherToAdd: Teacher?
        var teacherToEdit: Teacher?

        // MARK: - INIT

        init(dataManager: DataManager) {
            self.dataManager = dataManager
            setup()
        }

        // MARK: - Functions

        private func setup() {
            cancellable = dataManager.observeContextChanges(of: Teacher.self) { [weak self] in
                self?.updateTeachers()
            }
            updateTeachers()
        }

        private func updateTeachers() {
            teachers = dataManager.fetchTeachers(
                sortBy: [.init(\.name)]
            )
        }

        func hardDeleteTeacher(_ teacher: Teacher) throws {
            try dataManager.hardDeleteTeacher(teacher)
        }
    }
}
