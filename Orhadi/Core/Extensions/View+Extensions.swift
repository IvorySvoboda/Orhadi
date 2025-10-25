//
//  View+Extensions.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 26/04/25.
//

import SwiftUI

extension View {
    func plainListRow() -> some View {
        self
            .padding(.horizontal)
            .listRowBackground(Color.clear)
            .listRowInsets(
                EdgeInsets(
                    top: 0,
                    leading: 0,
                    bottom: 0,
                    trailing: 0
                )
            )
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

    var backport: Backport<Self> { Backport(self) }
}
