//
//  Theme+Extensions.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 30/10/25.
//

import SwiftUI

extension Theme {
    var colorScheme: ColorScheme? {
        switch self {
        case .auto: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
