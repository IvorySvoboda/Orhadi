//
//  OrhadiTheme.swift
//  Orhadi
//
//  Created by Zyvoxi . on 31/03/25.
//

import SwiftUICore

enum Theme: Int, Codable {
    case auto, light, dark
}

@Observable
class OrhadiTheme {

    var colorScheme: ColorScheme

    init(colorScheme: ColorScheme) {
        self.colorScheme = colorScheme
    }

    func bgColor() -> Color {
        switch colorScheme {
        case .dark:
            return Color(red: 0.02, green: 0.02, blue: 0.02)
        case .light:
            return Color(red: 0.94, green: 0.94, blue: 1)
        default:
            return Color(red: 0.02, green: 0.02, blue: 0.02)
        }
    }

    func bgColor(_ customColorScheme: ColorScheme) -> Color {
        switch customColorScheme {
        case .dark:
            return Color(red: 0.02, green: 0.02, blue: 0.02)
        case .light:
            return Color(red: 0.94, green: 0.94, blue: 1)
        default:
            return Color(red: 0.02, green: 0.02, blue: 0.02)
        }
    }


    func secondaryBGColor() -> Color {
        switch colorScheme {
        case .dark:
            return Color(red: 0.56, green: 0.56, blue: 0.56, opacity: 0.08)
        case .light:
            return Color(red: 0.56, green: 0.56, blue: 1, opacity: 0.085)
        default:
            return Color(red: 0.56, green: 0.56, blue: 0.56, opacity: 0.08)
        }
    }

    func secondaryBGColor(_ customColorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .dark:
            return Color(red: 0.56, green: 0.56, blue: 0.56, opacity: 0.08)
        case .light:
            return Color(red: 0.56, green: 0.56, blue: 1, opacity: 0.085)
        default:
            return Color(red: 0.56, green: 0.56, blue: 0.56, opacity: 0.08)
        }
    }

    func getTheme(for theme: Theme) -> ColorScheme? {
        switch theme {
        case .auto: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

}
