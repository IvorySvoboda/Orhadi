//
//  DeletedSubjectsViewModel.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 29/10/25.
//

import SwiftUI
import Observation
import Combine

extension DeletedSubjectsView {
    @Observable class ViewModel {
        // MARK: - Properties

        private let dataManager: DataManager
        private var cancellable: AnyCancellable?
        var deletedSubjects: [Subject] = []
        var selectedSubjects = Set<Subject>()
        var showDeleteConfirmation = false
        var showConflictAlert = false

        // MARK: - Computed Properties

        var countToActOn: Int {
            selectedSubjects.isEmpty ? deletedSubjects.count : selectedSubjects.count
        }

        var isPlural: Bool {
            countToActOn > 1
        }

        var deleteActionTitle: LocalizedStringKey {
            if isPlural {
                return "Delete \(countToActOn) Subjects"
            } else {
                return "Delete Subject"
            }
        }

        var deleteMessageText: LocalizedStringKey {
            if isPlural {
                return "These \(countToActOn) subjects will be deleted. This action cannot be undone."
            } else {
                return "This subject will be deleted. This action cannot be undone."
            }
        }

        // MARK: - INIT

        init(dataManager: DataManager) {
            self.dataManager = dataManager
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

        func hardDeleteSubject(_ subject: Subject) throws {
            try dataManager.hardDeleteSubject(subject)
        }

        func restoreSubject(_ subject: Subject) throws {
            let hasConflictWithOthersSubjects = dataManager.isSubjectScheduleInvalid(subject)

            if hasConflictWithOthersSubjects {
                showConflictAlert = true
            } else {
                try dataManager.restoreSubject(subject)
            }
        }

        func deleteSubjects() {
            if selectedSubjects.isEmpty {
                for subject in deletedSubjects {
                    try? hardDeleteSubject(subject)
                }
            } else {
                for subject in selectedSubjects {
                    try? hardDeleteSubject(subject)
                }
                selectedSubjects.removeAll()
            }
        }

        func restoreSubjects() {
            if selectedSubjects.isEmpty {
                for subject in deletedSubjects {
                    try? restoreSubject(subject)
                }
            } else {
                for subject in selectedSubjects {
                    try? restoreSubject(subject)
                }
                selectedSubjects.removeAll()
            }
        }
    }
}
