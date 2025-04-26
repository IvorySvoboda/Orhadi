//
//  StatisticsView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 26/04/25.
//

import SwiftUI

struct StatisticsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(GameManager.self) private var game
    @Environment(UserProfile.self) private var user
    @Environment(OrhadiTheme.self) private var theme

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Level")
                    Spacer()
                    Text("\(user.level)")
                        .foregroundStyle(Color.secondary)
                }
                HStack {
                    Text("XP")
                    Spacer()
                    Text("\(user.xp)/\(game.xpRequired(for: user.level))")
                        .foregroundStyle(Color.secondary)
                }
                HStack {
                    Text("Tempo estudado")
                    Spacer()
                    Text(formatTime(user.timeStudied))
                        .foregroundStyle(Color.secondary)
                }
                HStack {
                    Text("Tarefas completadas")
                    Spacer()
                    Text("\(user.completedToDos)")
                        .foregroundStyle(Color.secondary)
                }
            }.listRowBackground(theme.secondaryBGColor())
        }
        .modifier(DefaultList())
        .navigationTitle("Estatísticas")
        .navigationBarTitleDisplayMode(.inline)
    }
}
