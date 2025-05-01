//
//  Theme.swift
//  Orhadi
//
//  Created by Zyvoxi . on 30/04/25.
//

import Foundation

enum Theme: Codable, CaseIterable {
    case light, dark, auto

    var name: String {
        switch self {
        case .light:
            return String(localized: "Claro")
        case .dark:
            return String(localized: "Escuro")
        case .auto:
            return String(localized: "Auto")
        }
    }
}
