//
//  EmptyViewText.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 07/07/25.
//

import SwiftUI

struct EmptyViewText: View {
    var body: some View {
        Text("It looks like there's nothing else here. How about taking this opportunity to study a little?")
            .foregroundStyle(Color.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}
