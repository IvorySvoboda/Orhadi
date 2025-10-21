//
//  AttributedString+Extensions.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 20/10/25.
//

import SwiftUI

extension AttributedString {
    func lineRange(containing idx: AttributedString.Index) -> Range<AttributedString.Index> {
        var start = idx
        while start > self.startIndex {
            let prev = self.index(start, offsetByCharacters: -1)
            let char = String(self[prev..<self.index(afterCharacter: prev)].characters)
            if char == "\n" {
                start = self.index(afterCharacter: prev)
                break
            }
            start = prev
        }

        var end = idx
        while end < self.endIndex {
            let char = String(self[end..<self.index(afterCharacter: end)].characters)
            if char == "\n" {
                break
            }
            end = self.index(afterCharacter: end)
        }

        return start..<end
    }
}
