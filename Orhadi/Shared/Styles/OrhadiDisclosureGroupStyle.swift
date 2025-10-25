//
//  OrhadiDisclosureGroupStyle.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 27/03/25.
//

import SwiftUI

struct OrhadiDisclosureGroupStyle: DisclosureGroupStyle {

    var addPadding: Bool

    init(addPadding: Bool = true) {
        self.addPadding = addPadding
    }

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8)) {
                configuration.isExpanded.toggle()
            }
        }
        if configuration.isExpanded {
            configuration.content
                .padding(.leading, addPadding ? 30 : 0)
                .disclosureGroupStyle(self)
        }
    }
}
