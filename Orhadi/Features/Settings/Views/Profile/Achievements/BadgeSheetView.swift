//
//  BadgeSheetView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 26/04/25.
//

import SwiftUI

struct BadgeSheetView: View {

    var achievement: Achievement

    var body: some View {
        NavigationStack {
            ZStack {
                Color.orhadiBG
                    .ignoresSafeArea()

                VStack {
                    ZStack {
                        BadgeView(imageName: achievement.imageName)
                        if !achievement.isUnlocked {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 100))
                                .foregroundStyle(Color.gray)
                                .shadow(radius: 5)
                        }
                    }.frame(width: 250, height: 250)
                    VStack(spacing: 10) {
                        if let unlockedAt = achievement.unlockedAt, achievement.isUnlocked {
                            Text("Desbloqueada em \(unlockedAt.formatted(date: .abbreviated, time: .omitted))")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        Text("\(achievement.descriptionText)")
                            .multilineTextAlignment(.center)
                    }.padding()
                }
                .offset(y: -10)
            }
            .navigationTitle("\(achievement.name)")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
