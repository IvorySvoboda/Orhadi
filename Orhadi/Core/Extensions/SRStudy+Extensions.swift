//
//  SRStudy+Extensions.swift
//  Orhadi
//
//  Created by Zyvoxi . on 21/04/25.
//

import Foundation

extension SRStudy {
    var isForToday: Bool {
        let todayWeekday = Calendar.current.component(.weekday, from: Date())
        let studyWeekday = Calendar.current.component(.weekday, from: studyDay)
        return studyWeekday == todayWeekday
    }

    var hasStudiedThisWeek: Bool {
        Calendar.current.isDate(lastStudied, equalTo: Date(), toGranularity: .weekOfYear) 
    }

    var studyTimeInSeconds: TimeInterval {
        let components = Calendar.current.dateComponents([.hour, .minute], from: studyTime)
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        return TimeInterval(hours * 3600 + minutes * 60)
    }

    var studyTimeInMinutes: Int {
        let components = Calendar.current.dateComponents([.hour, .minute], from: studyTime)
        return (components.hour ?? 0) * 60 + (components.minute ?? 0)
    }
}
