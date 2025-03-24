//
//  Calendar+Extensions.swift
//  Orhadi
//
//  Created by Zyvoxi . on 01/04/25.
//

import Foundation

extension Calendar {
    static let weekdays: [Int: String] = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "EEEE"

        return (1...7).reduce(into: [:]) { result, day in
            if let date = Calendar.current.date(bySetting: .weekday, value: day, of: Date()) {
                result[day] = formatter.string(from: date).capitalized
            }
        }
    }()
}
