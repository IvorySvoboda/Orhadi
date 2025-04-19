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
        let predefined = [
            // XP Inicial
            Achievement(id: "first_xp", name: String(localized: "Primeiros Passos"), imageName: "star", descriptionText: String(localized: "Ganhe XP pela primeira vez"), difficultLevel: 0),

            // Níveis
            Achievement(id: "level_3", name: String(localized: "Aquecendo"), imageName: "flame", descriptionText: String(localized: "Chegue ao nível 3"), difficultLevel: 1),
            Achievement(id: "level_5", name: String(localized: "Subindo na Vida"), imageName: "flame", descriptionText: String(localized: "Chegue ao nível 5"), difficultLevel: 5),
            Achievement(id: "level_8", name: String(localized: "Persistente"), imageName: "flame.fill", descriptionText: String(localized: "Chegue ao nível 8"), difficultLevel: 10),
            Achievement(id: "level_10", name: String(localized: "Veterano"), imageName: "rosette", descriptionText: String(localized: "Chegue ao nível 10"), difficultLevel: 15),
            Achievement(id: "level_12", name: String(localized: "Dedicado"), imageName: "star.circle", descriptionText: String(localized: "Chegue ao nível 12"), difficultLevel: 20),
            Achievement(id: "level_15", name: String(localized: "Estudioso"), imageName: "graduationcap", descriptionText: String(localized: "Chegue ao nível 15"), difficultLevel: 25),
            Achievement(id: "level_20", name: String(localized: "Expert"), imageName: "graduationcap.fill", descriptionText: String(localized: "Chegue ao nível 20"), difficultLevel: 30),
            Achievement(id: "level_25", name: String(localized: "Lendário"), imageName: "trophy.fill", descriptionText: String(localized: "Chegue ao nível 25"), difficultLevel: 35),
            Achievement(id: "level_30", name: String(localized: "Sábio"), imageName: "lightbulb", descriptionText: String(localized: "Chegue ao nível 30"), difficultLevel: 40),
            Achievement(id: "level_40", name: String(localized: "Iluminado"), imageName: "lightbulb.fill", descriptionText: String(localized: "Chegue ao nível 40"), difficultLevel: 50),
            Achievement(id: "level_50", name: String(localized: "Mestre"), imageName: "star.fill", descriptionText: String(localized: "Chegue ao nível 50"), difficultLevel: 60),
            Achievement(id: "level_60", name: String(localized: "Imbatível"), imageName: "shield.lefthalf.filled", descriptionText: String(localized: "Chegue ao nível 60"), difficultLevel: 70),
            Achievement(id: "level_75", name: String(localized: "Supremo"), imageName: "shield.checkered", descriptionText: String(localized: "Chegue ao nível 75"), difficultLevel: 80),
            Achievement(id: "level_100", name: String(localized: "Lenda Viva"), imageName: "crown.fill", descriptionText: String(localized: "Chegue ao nível 100"), difficultLevel: 90),
            Achievement(id: "level_150", name: String(localized: "Imortal"), imageName: "sparkles", descriptionText: String(localized: "Chegue ao nível 150"), difficultLevel: 95),
            Achievement(id: "level_200", name: String(localized: "Mítico"), imageName: "wand.and.stars", descriptionText: String(localized: "Chegue ao nível 200"), difficultLevel: 100),
            Achievement(id: "level_300", name: String(localized: "Divino"), imageName: "star.circle.fill", descriptionText: String(localized: "Chegue ao nível 300"), difficultLevel: 150),
            Achievement(id: "level_500", name: String(localized: "Transcendente"), imageName: "infinity.circle", descriptionText: String(localized: "Chegue ao nível 500"), difficultLevel: 200),
            Achievement(id: "level_750", name: String(localized: "Ascendido"), imageName: "sun.max.fill", descriptionText: String(localized: "Chegue ao nível 750"), difficultLevel: 250),
            Achievement(id: "level_1000", name: String(localized: "O Escolhido"), imageName: "sparkle.magnifyingglass", descriptionText: String(localized: "Chegue ao nível 1000"), difficultLevel: 300),

            // XP Acumulado
            Achievement(id: "xp_250", name: String(localized: "Aprendiz"), imageName: "bolt", descriptionText: String(localized: "Ganhe 250 XP acumulados"), difficultLevel: 1),
            Achievement(id: "xp_500", name: String(localized: "Acumulador"), imageName: "bolt", descriptionText: String(localized: "Ganhe 500 XP"), difficultLevel: 5),
            Achievement(id: "xp_750", name: String(localized: "Experiente"), imageName: "bolt.fill", descriptionText: String(localized: "Ganhe 750 XP acumulados"), difficultLevel: 10),
            Achievement(id: "xp_1000", name: String(localized: "XP Explorer"), imageName: "sparkle", descriptionText: String(localized: "Ganhe 1.000 XP acumulados"), difficultLevel: 15),
            Achievement(id: "xp_1500", name: String(localized: "XP Hunter"), imageName: "sparkles", descriptionText: String(localized: "Ganhe 1.500 XP acumulados"), difficultLevel: 20),
            Achievement(id: "xp_2000", name: String(localized: "Maratonista de XP"), imageName: "flame.fill", descriptionText: String(localized: "Ganhe 2.000 XP acumulados"), difficultLevel: 25),
            Achievement(id: "xp_3000", name: String(localized: "XP Slayer"), imageName: "wand.and.stars", descriptionText: String(localized: "Ganhe 3.000 XP acumulados"), difficultLevel: 30),
            Achievement(id: "xp_5000", name: String(localized: "XP Master"), imageName: "rosette", descriptionText: String(localized: "Ganhe 5.000 XP acumulados"), difficultLevel: 40),
            Achievement(id: "xp_10000", name: String(localized: "XP Deus"), imageName: "crown", descriptionText: String(localized: "Ganhe 10.000 XP acumulados"), difficultLevel: 50),
            Achievement(id: "xp_25000", name: String(localized: "Colecionador de XP"), imageName: "archivebox.fill", descriptionText: String(localized: "Ganhe 25.000 XP acumulados"), difficultLevel: 60),
            Achievement(id: "xp_50000", name: String(localized: "XP Lord"), imageName: "globe.europe.africa.fill", descriptionText: String(localized: "Ganhe 50.000 XP acumulados"), difficultLevel: 70),
            Achievement(id: "xp_100000", name: String(localized: "Universo XP"), imageName: "moon.stars.fill", descriptionText: String(localized: "Ganhe 100.000 XP acumulados"), difficultLevel: 80),
            Achievement(id: "xp_250000", name: String(localized: "Energizado"), imageName: "bolt.circle.fill", descriptionText: String(localized: "Ganhe 250.000 XP acumulados"), difficultLevel: 90),
            Achievement(id: "xp_500000", name: String(localized: "Sobrecarga"), imageName: "bolt.trianglebadge.exclamationmark", descriptionText: String(localized: "Ganhe 500.000 XP acumulados"), difficultLevel: 95),
            Achievement(id: "xp_1000000", name: String(localized: "Divindade do XP"), imageName: "infinity", descriptionText: String(localized: "Ganhe 1.000.000 XP acumulados"), difficultLevel: 100),

            // Tempo de Estudo
            Achievement(id: "study_30min", name: String(localized: "Começo Brilhante"), imageName: "clock", descriptionText: String(localized: "Estude por 30 minutos no total"), difficultLevel: 1),
            Achievement(id: "study_1h", name: String(localized: "Focado"), imageName: "clock", descriptionText: String(localized: "Estude por 1 hora no total"), difficultLevel: 5),
            Achievement(id: "study_5h", name: String(localized: "Consistente"), imageName: "clock.badge.checkmark", descriptionText: String(localized: "Estude por 5 horas no total"), difficultLevel: 10),
            Achievement(id: "study_10h", name: String(localized: "Incansável"), imageName: "clock.fill", descriptionText: String(localized: "Estude por 10 horas no total"), difficultLevel: 15),
            Achievement(id: "study_25h", name: String(localized: "Constante"), imageName: "hourglass", descriptionText: String(localized: "Estude por 25 horas no total"), difficultLevel: 20),
            Achievement(id: "study_50h", name: String(localized: "Veterano de Estudos"), imageName: "hourglass.tophalf.filled", descriptionText: String(localized: "Estude por 50 horas no total"), difficultLevel: 30),
            Achievement(id: "study_100h", name: String(localized: "Mente Brilhante"), imageName: "brain", descriptionText: String(localized: "Estude por 100 horas no total"), difficultLevel: 40),
            Achievement(id: "study_200h", name: String(localized: "Estudante Supremo"), imageName: "brain.head.profile", descriptionText: String(localized: "Estude por 200 horas no total"), difficultLevel: 50),
            Achievement(id: "study_300h", name: String(localized: "Viciado em Conhecimento"), imageName: "books.vertical", descriptionText: String(localized: "Estude por 300 horas no total"), difficultLevel: 60),
            Achievement(id: "study_500h", name: String(localized: "Sábio Moderno"), imageName: "book.fill", descriptionText: String(localized: "Estude por 500 horas no total"), difficultLevel: 70),
            Achievement(id: "study_750h", name: String(localized: "Oráculo Acadêmico"), imageName: "book.circle.fill", descriptionText: String(localized: "Estude por 750 horas no total"), difficultLevel: 80),
            Achievement(id: "study_1000h", name: String(localized: "Estudioso Eterno"), imageName: "infinity.circle.fill", descriptionText: String(localized: "Estude por 1.000 horas no total"), difficultLevel: 90),
            Achievement(id: "study_1500h", name: String(localized: "Lenda dos Estudos"), imageName: "trophy.fill", descriptionText: String(localized: "Estude por 1.500 horas no total"), difficultLevel: 95),
            Achievement(id: "study_2000h", name: String(localized: "Mestre do Tempo"), imageName: "hourglass.bottomhalf.filled", descriptionText: String(localized: "Estude por 2.000 horas no total"), difficultLevel: 100),
            Achievement(id: "study_5000h", name: String(localized: "Imortal do Conhecimento"), imageName: "sparkles", descriptionText: String(localized: "Estude por 5.000 horas no total"), difficultLevel: 150),
            Achievement(id: "study_10000h", name: String(localized: "Deus do Estudo"), imageName: "crown.fill", descriptionText: String(localized: "Estude por 10.000 horas no total"), difficultLevel: 200),

            // Tarefas Concluídas
            Achievement(id: "todo_5", name: String(localized: "Começando a Organização"), imageName: "checkmark.seal", descriptionText: String(localized: "Complete 5 tarefas"), difficultLevel: 1),
            Achievement(id: "todo_25", name: String(localized: "Organização em Dia"), imageName: "checkmark.seal.fill", descriptionText: String(localized: "Complete 25 tarefas"), difficultLevel: 5),
            Achievement(id: "todo_75", name: String(localized: "Produtividade Total"), imageName: "list.bullet.clipboard", descriptionText: String(localized: "Complete 75 tarefas"), difficultLevel: 10),
            Achievement(id: "todo_200", name: String(localized: "Executor de Missões"), imageName: "checklist.checked", descriptionText: String(localized: "Complete 200 tarefas"), difficultLevel: 20),
            Achievement(id: "todo_500", name: String(localized: "Lenda da Produtividade"), imageName: "medal", descriptionText: String(localized: "Complete 500 tarefas"), difficultLevel: 30),
            Achievement(id: "todo_1000", name: String(localized: "To-Do Terminator"), imageName: "bolt.badge.checkmark", descriptionText: String(localized: "Complete 1.000 tarefas"), difficultLevel: 40),
            Achievement(id: "todo_2000", name: String(localized: "General da Rotina"), imageName: "checkmark.shield.fill", descriptionText: String(localized: "Complete 2.000 tarefas"), difficultLevel: 50),
            Achievement(id: "todo_3000", name: String(localized: "Executor Supremo"), imageName: "hammer.circle.fill", descriptionText: String(localized: "Complete 3.000 tarefas"), difficultLevel: 60),
            Achievement(id: "todo_5000", name: String(localized: "Workaholic"), imageName: "briefcase.fill", descriptionText: String(localized: "Complete 5.000 tarefas"), difficultLevel: 70),
            Achievement(id: "todo_10000", name: String(localized: "Lenda da Organização"), imageName: "crown.fill", descriptionText: String(localized: "Complete 10.000 tarefas"), difficultLevel: 80),
        ]

        let request = FetchDescriptor<Achievement>()
        if let existingAchievements = try? context.fetch(request) {
            let existingIDs = Set(existingAchievements.map { $0.id })

            let newAchievements = predefined.filter { !existingIDs.contains($0.id) }
            for achievement in newAchievements {
                context.insert(achievement)
            }

            if !newAchievements.isEmpty {
                try? context.save()
            }
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
        return 100 * level
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
        // XP inicial
        case "first_xp":
            return totalXP(user) > 0

        // Níveis
        case let id where id.starts(with: "level_"):
            if let level = Int(id.replacingOccurrences(of: "level_", with: "")) {
                return user.level >= level
            }

        // XP acumulado
        case let id where id.starts(with: "xp_"):
            if let xp = Int(id.replacingOccurrences(of: "xp_", with: "")) {
                return totalXP(user) >= xp
            }

        // Tempo estudado (segundos)
        case let id where id.starts(with: "study_"):
            let hourPart = id.replacingOccurrences(of: "study_", with: "").replacingOccurrences(of: "h", with: "")
            if let hourValue = Int(hourPart) {
                let requiredTime = hourValue * 60 * 60
                return user.timeStudied >= requiredTime
            } else if id == "study_30min" {
                return user.timeStudied >= 60 * 30
            }

        // Tarefas concluídas
        case let id where id.starts(with: "todo_"):
            if let todoCount = Int(id.replacingOccurrences(of: "todo_", with: "")) {
                return user.completedToDos >= todoCount
            }

        default:
            return false
        }

        return false
    }
}
