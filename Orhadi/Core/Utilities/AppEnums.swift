//
//  AppEnums.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 05/05/25.
//

import Foundation
import SwiftUI

enum Priority: Int, Codable, CaseIterable {
    case none = 0, low = 1, medium = 2, high = 3

    var priorityString: LocalizedStringKey {
        switch self {
        case .none:
            return "None"
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
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

    var name: LocalizedStringKey {
        switch self {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        case .auto:
            return "Auto"
        }
    }
}

enum ToDoSection: CaseIterable {
    case pending, completed

    var string: LocalizedStringKey {
        switch self {
        case .pending: return "Pending"
        case .completed: return "Completed"
        }
    }
}

enum MinimizeBehavior {
    case automatic, onScrollUp, onScrollDown, never
}
