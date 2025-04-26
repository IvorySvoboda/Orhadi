//
//  View+Extensions.swift
//  Orhadi
//
//  Created by Zyvoxi . on 26/04/25.
//

import SwiftUI

extension View {
    func orhadiListStyle() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(Color.orhadiBG)
            .toolbarBackground(Color.orhadiBG, for: .navigationBar)
    }

    func orhadiPlainListStyle() -> some View {
        self
            .listStyle(PlainListStyle())
            .background(Color.orhadiBG)
            .toolbarBackground(Color.orhadiBG, for: .navigationBar)
    }

    func disableIdleTimer() -> some View {
        self
            .onAppear {
                UIApplication.shared.isIdleTimerDisabled = true
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
            }
    }
}
