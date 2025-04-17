//
//  GameManager.swift
//  Orhadi
//
//  Created by Zyvoxi . on 16/04/25.
//

import SwiftData
import Foundation

@Observable
class GameManager {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
        setupAchievementsIfNeeded()
    }

    func setupAchievementsIfNeeded() {
        let request = FetchDescriptor<Achievement>()
        if let achievements = try? context.fetch(request), achievements.isEmpty {
            let predefined = [
                Achievement(id: "first_xp", name: "Primeiros Passos", imageName: "star", descriptionText: "Ganhe XP pela primeira vez"),
                Achievement(id: "level_5", name: "Subindo na Vida", imageName: "flame", descriptionText: "Chegue ao nível 5"),
                Achievement(id: "xp_500", name: "Acumulador", imageName: "bolt", descriptionText: "Ganhe 500 XP"),
                Achievement(id: "level_10", name: "Veterano", imageName: "rosette", descriptionText: "Chegue ao nível 10"),
                Achievement(id: "xp_2000", name: "Maratonista de XP", imageName: "flame.fill", descriptionText: "Ganhe 2000 XP acumulados"),
                Achievement(id: "study_1h", name: "Focado", imageName: "clock", descriptionText: "Estude por 1 hora no total"),
                Achievement(id: "study_10h", name: "Incansável", imageName: "clock.fill", descriptionText: "Estude por 10 horas no total"),
                Achievement(id: "level_15", name: "Estudioso", imageName: "graduationcap", descriptionText: "Chegue ao nível 15"),
                Achievement(id: "xp_1000", name: "XP Explorer", imageName: "sparkle", descriptionText: "Ganhe 1.000 XP acumulados"),
                Achievement(id: "study_25h", name: "Constante", imageName: "hourglass", descriptionText: "Estude por 25 horas no total"),
                Achievement(id: "study_100h", name: "Mente Brilhante", imageName: "brain", descriptionText: "Estude por 100 horas no total"),
                Achievement(id: "xp_5000", name: "XP Master", imageName: "rosette", descriptionText: "Ganhe 5.000 XP acumulados"),
                Achievement(id: "level_25", name: "Lendário", imageName: "trophy.fill", descriptionText: "Chegue ao nível 25"),
            ]
            for achievement in predefined {
                context.insert(achievement)
            }
            try? context.save()
        }
    }

    /// Calcula XP total somando níveis anteriores
    private func totalXP(_ user: UserProfile) -> Int {
        var total = user.xp
        for level in 1..<user.level {
            total += xpRequired(for: level)
        }
        return total
    }

    /// Calcula XP necessário para passar do nível atual
    func xpRequired(for level: Int) -> Int {
        // Fórmula escalável: pode ajustar aqui conforme quiser
        return 100 + (level - 1) * 50
    }

    /// Adiciona XP e aplica level up se necessário
    func addXP(_ amount: Int, to user: UserProfile) {
        user.xp += amount
        checkLevelUp(for: user)
        checkAchievements(for: user)
        try? context.save()
    }

    /// Verifica se deve subir de nível
    private func checkLevelUp(for user: UserProfile) {
        while user.xp >= xpRequired(for: user.level) {
            user.xp -= xpRequired(for: user.level)
            user.level += 1
        }
    }

    /// Verifica e desbloqueia conquistas atingidas
    func checkAchievements(for user: UserProfile) {
        if let achievements = try? context.fetch(FetchDescriptor<Achievement>()) {
            for achievement in achievements where !achievement.isUnlocked {
                if shouldUnlock(achievement: achievement, for: user) {
                    achievement.isUnlocked = true
                    achievement.unlockedAt = Date()
                }
            }
            try? context.save()
        }
    }

    func unlockAchievement(_ achievement: Achievement) {
        achievement.isUnlocked = true
        achievement.unlockedAt = Date()
    }

    /// Regras de desbloqueio
    private func shouldUnlock(achievement: Achievement, for user: UserProfile) -> Bool {
        switch achievement.id {
        case "first_xp":
            return user.xp > 0
        case "level_5":
            return user.level >= 5
        case "xp_500":
            return totalXP(user) >= 500
        case "level_10":
            return user.level >= 10
        case "xp_2000":
            return totalXP(user) >= 2000
        case "study_1h":
            return user.timeStudied >= 60 * 60
        case "study_10h":
            return user.timeStudied >= 60 * 60 * 10
        case "level_15":
            return user.level >= 15
        case "xp_1000":
            return totalXP(user) >= 1000
        case "study_25h":
            return user.timeStudied >= 60 * 60 * 25
        case "study_100h":
            return user.timeStudied >= 60 * 60 * 100
        case "xp_5000":
            return totalXP(user) >= 5000
        case "level_25":
            return user.level >= 25
        default:
            return false
        }
    }
}
