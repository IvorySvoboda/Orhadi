//
//  CustomLabel.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 22/04/25.
//

import SwiftUI

struct CustomLabel: View {

    var titleKey: LocalizedStringKey
    var systemImage: String

    init(_ titleKey: LocalizedStringKey, systemImage: String) {
        self.titleKey = titleKey
        self.systemImage = systemImage
    }

    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .frame(width: 10, alignment: .center)
            Text(titleKey)
                .lineLimit(1)
                .frame(maxWidth: 150, alignment: .leading)
        }
    }
}
