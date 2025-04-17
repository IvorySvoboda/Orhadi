//
//  FormatUtils.swift
//  Orhadi
//
//  Created by Zyvoxi . on 30/03/25.
//

import Foundation

/// Formata um `Date` em uma `String` no formato "(hora)h (minuto)m".
func formatHourAndMinute(_ date: Date) -> String {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.hour, .minute], from: date)

    var dateHour: Int = 0
    var dateMinute: Int = 0

    if let hour = components.hour, hour != 0 {
        dateHour = hour
    }

    if let minute = components.minute, minute != 0 {
        dateMinute = minute
    }

    guard !(dateHour == 0 && dateMinute == 0) else {
        return "Não Informado."
    }

    return "\(dateHour > 0 ? "\(dateHour)h " : "")\(dateMinute)m"
}

func formatHourAndMinute(_ time: TimeInterval) -> String {
    let time = Int(time)

    let dateHour = time / 3600
    let dateMinute = (time % 3600) / 60

    guard !(dateHour == 0 && dateMinute == 0) else {
        return "Não Informado."
    }

    return "\(dateHour > 0 ? "\(dateHour)h " : "")\(dateMinute)m"
}

func formatTime(_ int: Int) -> String {
    let hour = int / 3600
    let minutes = (int % 3600) / 60

    return "\(hour < 10 ? "0\(hour)" : "\(hour)"):\(minutes < 10 ? "0\(minutes)" : "\(minutes)")"
}

/// Formata um `Date` em uma `String` no formato "hh:mm".
func formatTime(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = String(localized: "HH:mm")

    return dateFormatter.string(from: date).capitalized
}

/// Formata um `Date` em uma `String` no formato "dd/MM/yyyy – hh:mm".
func formatDueDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = String(localized: "dd/MM/yyyy – HH:mm")

    return dateFormatter.string(from: date)
}
