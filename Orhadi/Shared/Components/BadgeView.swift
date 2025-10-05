//
//  BadgeView.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 18/04/25.
//

import SwiftUI

struct BadgeView: View {

    var imageName: String

    var body: some View {
            ZStack {
                /// Fundo Preto, talvez não o ideal. <- Revisar
                Circle()
                    .fill(.black)
                    .frame(width: 250)

                Circle()
                    .fill(LinearGradient(colors: [.accentColor, .accentColor.opacity(0.8), .accentColor.opacity(0.6), .accentColor.opacity(0.4), .accentColor.opacity(0.2)], startPoint: .topTrailing, endPoint: .bottomLeading))
                    .frame(width: 250)

                Circle()
                    .stroke(LinearGradient(colors: [.black.opacity(0.8), .black.opacity(0.6), .black.opacity(0.6), .black.opacity(0.6), .black.opacity(0.8)], startPoint: .topTrailing, endPoint: .bottomLeading).opacity(0.85), lineWidth: 6)
                    .frame(width: 243)

                Circle()
                    .stroke(.black, lineWidth: 5)
                    .frame(width: 245)
                Circle()
                    .stroke(LinearGradient(colors: [.accentColor.opacity(0.6), .accentColor, .accentColor.opacity(0.2)], startPoint: .topTrailing, endPoint: .bottomLeading), lineWidth: 5)
                    .frame(width: 245)

                Circle()
                    .fill(.black.opacity(0.85))
                    .frame(width: 237)
                Circle()
                    .stroke(.black, lineWidth: 3)
                    .frame(width: 235)
                    .blur(radius: 5)

                /// Imagem da Badge
                Image(systemName: imageName)
                    .font(.system(size: 97))
                    .foregroundStyle(LinearGradient(colors: [.accentColor, .accentColor.opacity(0.2)], startPoint: .topTrailing, endPoint: .bottomLeading).opacity(0.5))
                Image(systemName: imageName)
                    .font(.system(size: 100))
                    .foregroundStyle(Color.black)
                Image(systemName: imageName)
                    .font(.system(size: 100))
                    .foregroundStyle(LinearGradient(colors: [.accentColor, .accentColor.opacity(0.8), .accentColor.opacity(0.6), .accentColor.opacity(0.4), .accentColor.opacity(0.2)], startPoint: .topTrailing, endPoint: .bottomLeading))
                    .shadow(color: .black, radius: 5)

            }.frame(width: 250, height: 250)
        }
}

#Preview {
    BadgeView(imageName: "star")
}
