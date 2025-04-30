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

    func plainListRow() -> some View {
        self
            .padding(.horizontal)
            .listRowBackground(Color.clear)
            .listRowInsets(
                EdgeInsets(
                    top: -1,
                    leading: 0,
                    bottom: 0,
                    trailing: 0
                )
            )
            .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in 0 }
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
