//
//  SRViewModel.swift
//  Orhadi
//
//  Created by Zyvoxi . on 26/04/25.
//


import SwiftUI

@Observable
final class SRViewModel {
    private var allStudies: [SRStudy] = []

    var studyToAdd: SRStudy? = nil
    var studyToEdit: SRStudy? = nil
    var studiesToStudy: [SRStudy] = []
    var navigateToStudyingView: Bool = false
    var selectedDay: Int = Calendar.current.component(.weekday, from: Date())
    var scrollOffsetY: Int = 151

    var filteredStudies: [SRStudy] {
        allStudies.filter {
            Calendar.current.component(.weekday, from: $0.studyDay) == selectedDay
        }
    }
    
    var isTodayEmpty: Bool {
        filteredStudies.isEmpty
    }
    
    var studiesForToday: [SRStudy] {
        allStudies.filter { $0.isForToday && !$0.hasStudiedThisWeek }
    }
    
    var canStartStudying: Bool {
        !studiesForToday.isEmpty
    }
    
    var toolbarTitle: String {
        Calendar.current.weekdaySymbols[selectedDay - 1].uppercased()
    }

    // MARK: - Actions

    func updateStudies(_ studies: [SRStudy]) {
        self.allStudies = studies
    }
    
    func addNewStudy() {
        studyToAdd = SRStudy()
    }
    
    func prepareStudiesToStudy() {
        studiesToStudy = studiesForToday
        navigateToStudyingView = true
    }
    
    func updateScrollOffset(with newY: CGFloat) {
        withAnimation(.smooth(duration: 0.25)) {
            scrollOffsetY = Int(newY)
        }
    }
}
