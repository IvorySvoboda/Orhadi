//
//  Backport+Extensions.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 19/10/25.
//

import SwiftUI

extension Backport where Content: View {
    @ViewBuilder
    func tabBarMinimizeBehavior(_ behavior: MinimizeBehavior) -> some View {
        if #available(iOS 26, *) {
            content.tabBarMinimizeBehavior({
                switch behavior {
                case .automatic: .automatic
                case .onScrollUp: .onScrollUp
                case .onScrollDown: .onScrollDown
                case .never: .never
                }
            }())
        } else {
            content
        }
    }
}
