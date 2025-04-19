//
//  BadgeView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 18/04/25.
//

import SwiftUI

struct BadgeView: View {

    var imageName: String

    var body: some View {
            ZStack {
                Circle()
                    .fill(.black)
                    .frame(width: 250)
                Circle()
                    .stroke(LinearGradient(colors: [.indigo.opacity(0.2), .indigo.opacity(0.2), .indigo, .indigo.opacity(0.2), .indigo.opacity(0.2)], startPoint: .topTrailing, endPoint: .bottomLeading).opacity(0.85), lineWidth: 6)
                    .frame(width: 243)
                Circle()
                    .stroke(LinearGradient(colors: [.indigo, .indigo.opacity(0.2)], startPoint: .topTrailing, endPoint: .bottomLeading), lineWidth: 5)
                    .frame(width: 245)
                Circle()
                    .fill(LinearGradient(colors: [.indigo, .indigo.opacity(0.2)], startPoint: .topTrailing, endPoint: .bottomLeading))
                    .frame(width: 237)
                Circle()
                    .fill(.black.opacity(0.85))
                    .frame(width: 237)
                Circle()
                    .stroke(.black, lineWidth: 3)
                    .frame(width: 235)
                    .blur(radius: 5)
                Image(systemName: imageName)
                    .font(.system(size: 97))
                    .foregroundStyle(LinearGradient(colors: [.indigo, .indigo.opacity(0.2)], startPoint: .topTrailing, endPoint: .bottomLeading).opacity(0.5))
                Image(systemName: imageName)
                    .font(.system(size: 100))
                    .foregroundStyle(Color.black)
                Image(systemName: imageName)
                    .font(.system(size: 100))
                    .foregroundStyle(LinearGradient(colors: [.indigo, .indigo.opacity(0.2)], startPoint: .topTrailing, endPoint: .bottomLeading))
                    .shadow(color: .black, radius: 5)
            }.frame(width: 250, height: 250)
        }
}
