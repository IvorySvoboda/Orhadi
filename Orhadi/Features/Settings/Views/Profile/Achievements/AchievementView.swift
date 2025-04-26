//
//  AchievementView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 18/04/25.
//

import SwiftData
import SwiftUI

struct AchievementView: View {
    @Environment(GameManager.self) private var game

    @Query(sort: [
        SortDescriptor(\Achievement.isUnlocked, order: .reverse),
        SortDescriptor(\Achievement.difficultLevel, order: .forward),
        SortDescriptor(\Achievement.unlockedAt, order: .reverse),
    ]) private var achievements: [Achievement]

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    @State private var selectedAchievement: Achievement?

    var body: some View {
        List {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(achievements) { achievement in
                    VStack(spacing: 15) {
                        ZStack {
                            BadgeView(imageName: achievement.imageName)
                                .scaleEffect(0.32)
                            if !achievement.isUnlocked {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(Color.gray)
                                    .shadow(radius: 15)
                            }
                        }.frame(width: 80, height: 80)
                        Text(achievement.name)
                            .lineLimit(1)
                            .font(.subheadline)
                            .opacity(achievement.isUnlocked ? 1 : 0.5)
                    }
                    .onTapGesture {
                        selectedAchievement = achievement
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(Text(achievement.name))
                    .accessibilityHint(achievement.isUnlocked ? Text("Conquista desbloqueada") : Text("Conquista bloqueada"))
                }
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .compositingGroup()
            .drawingGroup()
        }
        .orhadiPlainListStyle()
        .navigationTitle("Conquistas")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.orhadiBG, for: .navigationBar)
        .sheet(item: $selectedAchievement, onDismiss: { selectedAchievement = nil }) { achievement in
            BadgeSheetView(achievement: achievement)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}
