//
//  Achievement.swift
//  Orhadi
//
//  Created by Zyvoxi . on 29/04/25.
//

import SwiftData
import Foundation

extension OrhadiSchemaV1 {
    @Model
    class Achievement {
        @Attribute(.unique) var id: String
        var name: String
        var imageName: String
        var descriptionText: String
        var isUnlocked: Bool
        var unlockedAt: Date?
        var difficultLevel: Int

        init(
            id: String,
            name: String,
            imageName: String,
            descriptionText: String,
            isUnlocked: Bool = false,
            unlockedAt: Date? = nil,
            difficultLevel: Int
        ) {
            self.id = id
            self.name = name
            self.imageName = imageName
            self.descriptionText = descriptionText
            self.isUnlocked = isUnlocked
            self.unlockedAt = unlockedAt
            self.difficultLevel = difficultLevel
        }
    }
}
