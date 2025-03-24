//
//  SectionHeader.swift
//  Orhadi
//
//  Created by Zyvoxi . on 01/04/25.
//

import SwiftUI

struct SectionHeader: View {
    @Environment(\.colorScheme) private var colorScheme

    var text: String

    var body: some View {
        HStack {
            Text("\(text)")
                .padding(
                    EdgeInsets(
                        top: 4,
                        leading: 15,
                        bottom: 4,
                        trailing: 0)
                )

            Spacer()
        }
        .background(OrhadiTheme.getBackgroundColor(for: colorScheme))
        .listRowInsets(
            EdgeInsets(
                top: 0,
                leading: 0,
                bottom: 0,
                trailing: 0)
        )
    }
}
