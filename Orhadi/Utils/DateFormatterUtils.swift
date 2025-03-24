//
//  DateFormatterUtils.swift
//  Orhadi
//
//  Created by Zyvoxi . on 30/03/25.
//

import Foundation

/// Formata um `Date` em uma `String` no formato "hh:mm - EEEE".
func formatTime(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = String(localized: "HH:mm")

    return dateFormatter.string(from: date).capitalized
}

/// Formata um `Date` em uma `String` no formato "dd/MM/yyyy - hh:mm".
func formatDueDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = String(localized: "dd/MM/yyyy - HH:mm")

    return dateFormatter.string(from: date)
}
