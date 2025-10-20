//
//  Backport.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 19/10/25.
//

import SwiftUI

public struct Backport<Content> {
    public let content: Content

    public init(_ content: Content) {
        self.content = content
    }
}
