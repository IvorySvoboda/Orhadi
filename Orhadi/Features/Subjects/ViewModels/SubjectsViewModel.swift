//
//  SubjectsViewModel.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 22/10/25.
//

import SwiftUI
import SwiftData
import Observation

extension SubjectsView {
    @Observable class ViewModel {
        var context: ModelContext?
        var subjects: [Subject] = []
        var selectedDay: Int = Calendar.current.component(.weekday, from: Date())
        var showConfirmation: Bool = false
        var subjectToAdd: Subject?
        var subjectToEdit: Subject?
        var showTitle: Bool = false
        var showSelectedWeekday: Bool = false
        var hideOverlay: Bool = false

        var filteredSubjects: [Subject] {
            subjects.filter {
                Calendar.current.component(.weekday, from: $0.schedule) == selectedDay
            }
        }

        var toolbarTitle: String {
            Calendar.current.weekdaySymbols[selectedDay - 1].uppercased()
        }

        func fetchSubjects() {
            guard let context else { return }
            debugPrint("Subjects: fetching...")
            do {
                let descriptor = FetchDescriptor<Subject>(predicate: #Predicate {
                    !$0.isSubjectDeleted
                }, sortBy: [.init(\.startTime)])
                subjects = try context.fetch(descriptor)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }

        func handleScrollGeoChange(_ scrollOffset: CGFloat) {
            debugPrint(scrollOffset)

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

            let shouldHideOverlay = scrollOffset < -300
            if shouldHideOverlay != hideOverlay {
                withAnimation(.smooth(duration: 0.5)) {
                    hideOverlay = shouldHideOverlay
                }
            }
        }
    }
}
