//
//  Foundation+Extensions.swift
//  Orhadi
//
//  Created by Zyvoxi . on 05/05/25.
//

import Foundation

extension Bool: @retroactive Comparable {
    public static func <(lhs: Self, rhs: Self) -> Bool {
        return !lhs && rhs
    }
}

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

extension NSRange {
    func toRange(in text: String) -> Range<String.Index>? {
        guard
            let from = text.index(text.startIndex, offsetBy: location, limitedBy: text.endIndex),
            let to = text.index(from, offsetBy: length, limitedBy: text.endIndex)
        else {
            return nil
        }
        return from..<to
    }
}

extension String {
    func nilIfEmpty() -> String? {
        return isEmpty ? nil : self
    }
}

extension TimeInterval {
    func formatToHour() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: self) ?? "00:00"
    }
}
