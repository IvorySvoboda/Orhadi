//
//  Date+Extensions.swift
//  Orhadi
//
//  Created by Zyvoxi . on 29/04/25.
//

import Foundation

extension Date {
    func formatToHour() -> String {
        return self.formatted(date: .omitted, time: .shortened)
    }

    func relativeFormated() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        formatter.doesRelativeDateFormatting = true
        return formatter.string(from: self)
    }
}
