//
//  SubjectsViewModel.swift
//  Orhadi
//
//  Created by Zyvoxi . on 26/04/25.
//

import SwiftUI

@Observable class SubjectsViewModel {
    var allSubjects = [Subject]()

    var selectedDay: Int = Calendar.current.component(.weekday, from: Date())
    var showConfirmationDialog: Bool = false
    var subjectToAdd: Subject? = nil
    var subjectToEdit: Subject? = nil
    var scrollOffsetY: Int = 151

    var filteredSubjects: [Subject] {
        allSubjects.filter {
            Calendar.current.component(.weekday, from: $0.schedule) == selectedDay
        }
    }

    var hasSubjectsToday: Bool {
        filteredSubjects.isEmpty
    }

    var titleForToolbar: String {
        Calendar.current.weekdaySymbols[selectedDay - 1].uppercased()
    }

    // MARK: - Actions

    func updateSubjects(_ subjects: [Subject]) {
        self.allSubjects = subjects
    }

    func toggleConfirmationDialog() {
        showConfirmationDialog.toggle()
    }

    func prepareNewSubject(isRecess: Bool) {
        subjectToAdd = Subject(isRecess: isRecess)
    }

    func updateScrollOffset(with newY: CGFloat) {
        withAnimation(.smooth(duration: 0.25)) {
            scrollOffsetY = Int(newY)
        }
    }
}
