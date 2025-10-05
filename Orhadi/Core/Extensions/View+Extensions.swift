//
//  View+Extensions.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 26/04/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func orhadiListStyle() -> some View {
        if #available(iOS 26, *) {
            self
//                .scrollContentBackground(.hidden)
//                .background(Color.orhadiBG)
        } else {
            self
                .scrollContentBackground(.hidden)
                .background(Color.orhadiBG)
                .toolbarBackground(Color.orhadiBG, for: .navigationBar)
        }
    }

    @ViewBuilder
    func orhadiPlainListStyle() -> some View {
        if #available(iOS 26, *) {
            self
                .listStyle(.plain)
//                .background(Color.orhadiBG)
        } else {
            self
                .listStyle(.plain)
                .background(Color.orhadiBG)
                .toolbarBackground(Color.orhadiBG, for: .navigationBar)
        }
    }

    @ViewBuilder
    func iOS26GlassEffect(tinted: Bool = false) -> some View {
        if #available(iOS 26, *) {
            self
                .glassEffect(tinted ? .regular.interactive().tint(Color.accentColor) : .regular.interactive())
        } else {
            self
        }
    }

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
}
