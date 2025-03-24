//
//  TimeUtils.swift
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
