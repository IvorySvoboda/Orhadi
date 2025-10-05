//
//  AppEnums.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 05/05/25.
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
            return String(localized: "None")
        case .low:
            return String(localized: "Low")
        case .medium:
            return String(localized: "Medium")
        case .high:
            return String(localized: "High")
        }
    }
}

extension Priority: Comparable {
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

enum Theme: Codable, CaseIterable {
    case light, dark, auto

    var name: String {
        switch self {
        case .light:
            return String(localized: "Light")
        case .dark:
            return String(localized: "Dark")
        case .auto:
            return String(localized: "Auto")
        }
    }
}

enum ToDoSection: CaseIterable {
    case pending, completed

    var string: String {
        switch self {
        case .pending: return String(localized: "Pending")
        case .completed: return String(localized: "Completed")
        }
    }
}
