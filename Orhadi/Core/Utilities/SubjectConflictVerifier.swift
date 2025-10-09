//
//  SubjectConflictVerifier.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 08/10/25.
//

import SwiftData
import Foundation

func hasConflictsInTime(id: String?, start: Date, end: Date, schedule: Date) -> Bool {
    let container = try? createContainer()

    guard let container else { return false }

    let context = ModelContext(container)

    let subjects = try? context.fetch(FetchDescriptor<Subject>(predicate: #Predicate {
        !$0.isSubjectDeleted
    }))

    guard let subjects else { return false }

    let selectedWeekday = Calendar.current.component(.weekday, from: schedule)
    let sameScheduleSubjects = subjects.filter { other in
        let otherWeekday = Calendar.current.component(.weekday, from: other.schedule)
        return otherWeekday == selectedWeekday && (id != nil ? other.id != id : true)
    }

    let conflictSubjects = sameScheduleSubjects.filter { other in
        let conflictTest = (other.startTime <= start && other.endTime > start) ||
        (other.startTime < end && other.endTime >= end) ||
        (start <= other.startTime && end >= other.endTime)

        if conflictTest {
            debugPrint((other.startTime <= start && other.endTime > start))
            debugPrint((other.startTime < end && other.endTime >= end))
            debugPrint((start <= other.startTime && end >= other.endTime))
        }

        return conflictTest
    }

#if DEBUG
    debugPrint("Subjects:")
    for subject in subjects {
        debugPrint(subject.name)
    }

    debugPrint("Same schedule subjects:")
    for sameScheduleSubject in sameScheduleSubjects {
        debugPrint(sameScheduleSubject.name)
    }

    debugPrint("Conflict Subjects")
    for conflictSubject in conflictSubjects {
        debugPrint(conflictSubject.name)
    }
#endif // DEBUG

    return !conflictSubjects.isEmpty
}
