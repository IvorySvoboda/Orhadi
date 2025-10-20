//
//  NSRange+Extensions.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 18/10/25.
//

import Foundation

extension NSRange {
    func toRange(in text: String) -> Range<String.Index>? {
        guard
            let from = text.index(text.startIndex, offsetBy: location, limitedBy: text.endIndex),
            let to = text.index(from, offsetBy: length, limitedBy: text.endIndex)
        else {
            return nil
        }
        return from..<to
    }
}
