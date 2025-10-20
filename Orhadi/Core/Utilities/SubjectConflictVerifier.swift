//
//  SubjectConflictVerifier.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 08/10/25.
//

import SwiftData
import Foundation

class SubjectConflictVerifier {
    static func hasConflictWithOtherSubjects(
        id: PersistentIdentifier?,
        start: Date,
        end: Date,
        schedule: Date,
        context: ModelContext
    ) -> Bool {
        guard let subjects = try? context.fetch(FetchDescriptor<Subject>(predicate: #Predicate { !$0.isSubjectDeleted })) else {
            return false
        }

        let sameScheduleSubjects = subjects.filter { other in
            let calendar = Calendar.current
            let otherWeekday = calendar.component(.weekday, from: other.schedule)
            let subjectWeekday = calendar.component(.weekday, from: schedule)

            return otherWeekday == subjectWeekday && (id != nil ? other.id != id : true)
        }

        let conflictSubjects = sameScheduleSubjects.filter { other in
            (start < other.endTime) && (end > other.startTime)
        }

        return !conflictSubjects.isEmpty
    }

    static func hasInternalConflict(start: Date, end: Date) -> Bool {
        return end <= start
    }

    static func hasConflict(
        id: PersistentIdentifier?,
        start: Date,
        end: Date,
        schedule: Date,
        context: ModelContext
    ) -> Bool {
        return hasConflictWithOtherSubjects(
            id: id,
            start: start,
            end: end,
            schedule: schedule,
            context: context
        ) || hasInternalConflict(
            start: start,
            end: end
        )
    }
}
