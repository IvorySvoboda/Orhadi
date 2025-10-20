//
//  Date+Extensions.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 18/10/25.
//

import Foundation

extension Date {
    private static let relativeDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    func formatToHour() -> String {
        return self.formatted(date: .omitted, time: .shortened)
    }

    func relativeFormatted() -> String {
        return Date.relativeDateFormatter.string(from: self)
    }
}
