//
//  EmptyViewText.swift
//  Orhadi
//
//  Created by Zyvoxi . on 07/07/25.
//

import SwiftUI

struct EmptyViewText: View {
    var body: some View {
        Text("Parece que não tem mais nada por aqui. Que tal aproveitar pra estudar um pouco?")
            .foregroundStyle(Color.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}
