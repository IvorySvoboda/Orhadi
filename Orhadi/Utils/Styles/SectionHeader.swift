//
//  SectionHeader.swift
//  Orhadi
//
//  Created by Zyvoxi . on 01/04/25.
//

import SwiftUI

struct SectionHeader: View {
    @Environment(OrhadiTheme.self) private var theme

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
        .background(theme.bgColor())
        .listRowInsets(
            EdgeInsets(
                top: 0,
                leading: 0,
                bottom: 0,
                trailing: 0)
        )
    }
}
