//
//  Bool+Extensions.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 18/10/25.
//

import Foundation

extension Bool: @retroactive Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        return !lhs && rhs
    }

    static var iOS26: Bool {
        guard #available(iOS 26, *) else {
            return false
        }
        return true
    }
}
