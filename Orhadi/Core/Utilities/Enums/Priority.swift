//
//  Priority.swift
//  Orhadi
//
//  Created by Zyvoxi . on 30/04/25.
//

import Foundation

enum Priority: Int, Codable, CaseIterable {
    case none = 0
    case low = 1
    case medium = 2
    case high = 3

    var priorityString: String {
        switch self {
        case .none:
            return String(localized: "Nenhuma")
        case .low:
            return String(localized: "Baixa")
        case .medium:
            return String(localized: "Média")
        case .high:
            return String(localized: "Alta")
        }
    }
}

extension Priority: Comparable {
    static func <(lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
