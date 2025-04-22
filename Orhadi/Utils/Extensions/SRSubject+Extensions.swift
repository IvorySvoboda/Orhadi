//
//  SRSubject+Extensions.swift
//  Orhadi
//
//  Created by Zyvoxi . on 21/04/25.
//

import Foundation

extension SRSubject {
    var isForToday: Bool {
        let todayWeekday = Calendar.current.component(.weekday, from: Date())
        let studyWeekday = Calendar.current.component(.weekday, from: studyDay)
        return studyWeekday == todayWeekday
    }

    var hasStudiedThisWeek: Bool {
        Calendar.current.isDate(lastStudied, equalTo: Date(), toGranularity: .weekOfYear) 
    }
}
