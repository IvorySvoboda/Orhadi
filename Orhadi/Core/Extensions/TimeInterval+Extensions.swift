//
//  TimeInterval+Extensions.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 18/10/25.
//

import Foundation

extension TimeInterval {
    func formatToHour() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: self) ?? "00:00"
    }

    func durationString() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = self >= 3600 ? [.hour, .minute] : [.minute]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: self) ?? "0m"
    }
}
