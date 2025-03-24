//
//  CustomDisclosureGroupStyle.swift
//  Orhadi
//
//  Created by Zyvoxi . on 27/03/25.
//

import SwiftUI

struct CustomDisclosureGroupStyle: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                configuration.isExpanded.toggle()
            }
        }
        if configuration.isExpanded {
            configuration.content
                .padding(.leading, 30)
                .disclosureGroupStyle(self)
        }
    }
}
