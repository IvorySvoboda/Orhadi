//
//  Subject+Extensions.swift
//  Orhadi
//
//  Created by Zyvoxi . on 19/04/25.
//

import Foundation

extension Subject {
    static func defaultStartTime() -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: Date())
        components.year = 0
        components.month = 1
        components.day = 1
        components.hour = 7
        return Calendar.current.date(from: components) ?? Date()
    }

    static func defaultSchedule() -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .weekday], from: Date())
        components.year = 0
        components.month = 1
        return Calendar.current.date(from: components) ?? Date()
    }
}
