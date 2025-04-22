//
//  DefaultList.swift
//  Orhadi
//
//  Created by Zyvoxi . on 21/04/25.
//

import SwiftUI

struct DefaultList: ViewModifier {
    @Environment(OrhadiTheme.self) private var theme

    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background(theme.bgColor())
            .toolbarBackground(theme.bgColor(), for: .navigationBar)
    }
}
