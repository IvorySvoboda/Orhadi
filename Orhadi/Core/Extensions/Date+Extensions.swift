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

    var friendlyDateString: String {
        let calendar = Calendar.current

        // Determina se a hora deve ser exibida (considera apenas hora e minuto)
        let hour = calendar.component(.hour, from: self)
        let minute = calendar.component(.minute, from: self)
        let withHour = hour != 0 || minute != 0

        // Datas limites
        guard let twoDaysAhead = calendar.date(byAdding: .day, value: 2, to: .now),
              let twoDaysAgo = calendar.date(byAdding: .day, value: -3, to: .now) else {
            return ""
        }

        let formatter = DateFormatter()

        if self > twoDaysAhead || self <= twoDaysAgo {
            formatter.dateFormat = withHour ? "dd/MM/yyyy, HH:mm" : "dd/MM/yyyy"
        } else {
            formatter.timeStyle = withHour ? .short : .none
            formatter.dateStyle = .medium
            formatter.doesRelativeDateFormatting = true
        }

        return formatter.string(from: self)
    }
}
