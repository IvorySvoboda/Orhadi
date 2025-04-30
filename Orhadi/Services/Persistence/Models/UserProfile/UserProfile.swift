//
//  UserProfile.swift
//  Orhadi
//
//  Created by Zyvoxi . on 29/04/25.
//

import SwiftData
import Foundation

extension OrhadiSchemaV1 {
    @Model
    class UserProfile {
        @Attribute(.unique) var name: String
        var photo: Data?
        var level: Int
        var xp: Int
        var timeStudied: Int
        var completedToDos: Int

        init(
            name: String = "Orhadi",
            photo: Data? = nil,
            level: Int = 1,
            xp: Int = 0,
            timeStudied: Int = 0,
            completedToDos: Int = 0
        ) {
            self.name = name
            self.photo = photo
            self.level = level
            self.xp = xp
            self.timeStudied = timeStudied
            self.completedToDos = completedToDos
        }
    }
}
