//
//  SRViewModel.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 22/10/25.
//

import Observation
import SwiftData
import SwiftUI

extension SRView {
    @Observable class ViewModel {
        // MARK: - Properties

        var context: ModelContext
        var studies: [SRStudy] = []
        var studyToAdd: SRStudy?
        var studyToEdit: SRStudy?
        var studiesToStudy: [SRStudy] = []
        var navigateToStudyingView: Bool = false
        var selectedDay: Int = Calendar.current.component(.weekday, from: Date())
        var showTitle: Bool = false
        var showSelectedWeekday: Bool = false
        var hideOverlay: Bool = false

        // MARK: - Computed Properties

        var toolbarTitle: String {
            Calendar.current.weekdaySymbols[selectedDay - 1].uppercased()
        }

        var filteredStudies: [SRStudy] {
            studies.filter {
                Calendar.current.component(.weekday, from: $0.studyDay)
                    == selectedDay
            }
        }

        var studiesForTheSelectedDay: [SRStudy] {
            filteredStudies.filter { !$0.hasStudiedThisWeek }
        }

        var canStartStudying: Bool {
            !studiesForTheSelectedDay.isEmpty
        }

        // MARK: - INIT

        init(context: ModelContext) {
            self.context = context
            fetchStudies()
        }

        // MARK: - Functions

        func fetchStudies() {
            do {
                let descriptor = FetchDescriptor<SRStudy>(
                    predicate: #Predicate { !$0.isStudyDeleted }
                )

                studies = try context.fetch(descriptor)
            } catch {
                print(error.localizedDescription)
            }
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
