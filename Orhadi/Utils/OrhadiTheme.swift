//
//  OrhadiTheme.swift
//  Orhadi
//
//  Created by Zyvoxi . on 31/03/25.
//

import SwiftUICore

enum OrhadiTheme {

    static func getBackgroundColor(for theme: ColorScheme) -> Color {
        switch theme {
        case .dark: return Color(red: 0.05, green: 0.05, blue: 0.05)
        case .light: return Color(red: 0.94, green: 0.94, blue: 1)
        default: return Color(red: 0.05, green: 0.05, blue: 0.05)
        }
    }

    static func getSecondaryBGColor(for theme: ColorScheme) -> Color {
        switch theme {
        case .dark: return Color(red: 0.56, green: 0.56, blue: 0.56, opacity: 0.05)
        case .light: return Color(red: 0.56, green: 0.56, blue: 0.79, opacity: 0.08)
        default: return Color(red: 0.56, green: 0.56, blue: 0.56, opacity: 0.05)
        }
    }

    static func getAccentColor(from accentColor: Int) -> Color {
        switch accentColor {
        case 0: return Color.accentColor
        case 1: return Color.green
        case 2: return Color.red
        case 3: return Color.purple
        case 4: return Color.orange
        case 5: return Color.indigo
        case 6: return Color.cyan
        case 7: return Color.yellow
        case 8: return Color.pink
        default: return Color.accentColor
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
