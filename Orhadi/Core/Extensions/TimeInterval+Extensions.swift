//
//  TimeInterval+Extensions.swift
//  Orhadi
//
//  Created by Zyvoxi . on 29/04/25.
//

import Foundation

extension TimeInterval {
    func formatToHour() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: self)!
    }
}
