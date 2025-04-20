//
//  List+Extensions.swift
//  Orhadi
//
//  Created by Zyvoxi . on 20/04/25.
//

import SwiftUI

extension List {
    func defaultList(_ theme: OrhadiTheme) -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(theme.bgColor())
            .toolbarBackground(theme.bgColor(), for: .navigationBar)
    }

    func defaultPlainList(_ theme: OrhadiTheme) -> some View {
        self
            .listStyle(PlainListStyle())
            .background(theme.bgColor())
            .toolbarBackground(theme.bgColor(), for: .navigationBar)
    }
}

extension Form {
    func defaultList(_ theme: OrhadiTheme) -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(theme.bgColor())
            .toolbarBackground(theme.bgColor(), for: .navigationBar)
    }

    func defaultPlainList(_ theme: OrhadiTheme) -> some View {
        self
            .listStyle(PlainListStyle())
            .background(theme.bgColor())
            .toolbarBackground(theme.bgColor(), for: .navigationBar)
    }
}
