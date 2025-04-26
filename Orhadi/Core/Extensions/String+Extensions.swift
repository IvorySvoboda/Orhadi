//
//  String+Extensions.swift
//  Orhadi
//
//  Created by Zyvoxi . on 19/04/25.
//

import Foundation

extension String {
    func nilIfEmpty() -> String? {
        isEmpty ? nil : self
    }
}
