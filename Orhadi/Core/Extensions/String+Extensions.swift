//
//  String+Extensions.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 18/10/25.
//

import Foundation

extension String {
    func nilIfEmpty() -> String? {
        return isEmpty ? nil : self
    }
}
