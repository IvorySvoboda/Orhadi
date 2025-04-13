//
//  OrhadiTheme.swift
//  Orhadi
//
//  Created by Zyvoxi . on 31/03/25.
//

import SwiftUICore

enum OrhadiTheme {

    static func getBGColor(for theme: ColorScheme) -> Color {
        switch theme {
        case .dark: return Color(red: 0.05, green: 0.05, blue: 0.05)
        case .light: return Color(red: 0.94, green: 0.94, blue: 1)
        default: return Color(red: 0.05, green: 0.05, blue: 0.05)
        }
    }

    static func getSecondaryBGColor(for theme: ColorScheme) -> Color {
        switch theme {
        case .dark: return Color(red: 0.56, green: 0.56, blue: 0.56, opacity: 0.08)
        case .light: return Color(red: 0.56, green: 0.56, blue: 1, opacity: 0.08)
        default: return Color(red: 0.56, green: 0.56, blue: 0.56, opacity: 0.08)
        }
    }

    static func getTheme(for theme: Theme) -> ColorScheme? {
        switch theme {
        case .auto: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

}
