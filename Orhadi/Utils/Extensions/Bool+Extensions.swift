//
//  Bool+Extensions.swift
//  Orhadi
//
//  Created by Zyvoxi . on 17/04/25.
//

import Foundation

extension Bool: @retroactive Comparable {
    public static func <(lhs: Self, rhs: Self) -> Bool {
        !lhs && rhs
    }
}
