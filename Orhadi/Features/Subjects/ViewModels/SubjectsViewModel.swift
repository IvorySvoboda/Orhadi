//
//  SubjectsViewModel.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 22/10/25.
//

import Observation
import SwiftData
import SwiftUI
import Combine

extension SubjectsView {
    @Observable class ViewModel {
        // MARK: - Properties

        private let dataManager: DataManager
        private var cancellable: AnyCancellable?
        var subjects: [Subject] = []
        var selectedDay = Calendar.current.component(.weekday, from: Date())
        var showConfirmation = false
        var subjectToAdd: Subject?
        var subjectToEdit: Subject?
        var showTitle = false
        var showSelectedWeekday = false
        var hideOverlay = false

        // MARK: - Computed Properties

        var filteredSubjects: [Subject] {
            subjects.filter {
                Calendar.current.component(.weekday, from: $0.schedule) == selectedDay
            }
        }

        var toolbarTitle: String {
            Calendar.current.weekdaySymbols[selectedDay - 1].uppercased()
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
            subjects = dataManager.fetchSubjects(
                predicate: #Predicate { !$0.isSubjectDeleted },
                sortBy: [.init(\.startTime)]
            )
        }

        func softDeleteSubject(_ subject: Subject) throws {
            try dataManager.softDeleteSubject(subject)
        }

        func handleScrollGeoChange(_ scrollOffset: CGFloat) {
            let shouldShowTitle = scrollOffset >= -101
            if shouldShowTitle != showTitle {
                withAnimation(.smooth(duration: 0.5)) {
                    showTitle = shouldShowTitle
                }
            }

            let shouldShowWeekday = scrollOffset >= -56
            if shouldShowWeekday != showSelectedWeekday {
                withAnimation(.smooth(duration: 0.5)) {
                    showSelectedWeekday = shouldShowWeekday
                }
            }

            let shouldHideOverlay = scrollOffset <= -300
            if shouldHideOverlay != hideOverlay {
                withAnimation(.smooth(duration: 0.5)) {
                    hideOverlay = shouldHideOverlay
                }
            }
        }
    }
}
