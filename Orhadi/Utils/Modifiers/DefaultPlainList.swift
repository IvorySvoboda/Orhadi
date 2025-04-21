//
//  DefaultPlainList.swift
//  Orhadi
//
//  Created by Zyvoxi . on 21/04/25.
//

import SwiftUI

struct DefaultPlainList: ViewModifier {
    @Environment(OrhadiTheme.self) private var theme

    func body(content: Content) -> some View {
        content
            .listStyle(PlainListStyle())
            .background(theme.bgColor())
            .toolbarBackground(theme.bgColor(), for: .navigationBar)
    }
}
