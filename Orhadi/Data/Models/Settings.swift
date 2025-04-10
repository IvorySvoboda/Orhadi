//
//  Settings.swift
//  Orhadi
//
//  Created by Zyvoxi . on 30/03/25.
//

import Foundation
import SwiftData

enum Theme: Int, Codable {
    case auto, light, dark
}

enum SettingsSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Settings.self]
    }

    @Model
    class Settings {
        /// App
        var theme: Theme
        var accentColor: Int
        var swipeActions: Bool
        var editButton: Bool

        /// Study Routine
        var breakTime: TimeInterval
        var sharedSubjects: Bool
        var srsubjectsDeleteButton: Bool
        var srsubjectsDeleteConfirmation: Bool
        var liveActivity: Bool

        /// Subjects
        var subjectsDeleteButton: Bool
        var subjectsDeleteConfirmation: Bool

        /// ToDos
        var scheduleNotifications: Bool
        var todosDeleteConfirmation: Bool
        var todosDeleteButton: Bool

        init(
            theme: Theme = .auto,
            accentColor: Int = 0,
            swipeActions: Bool = true,
            editButton: Bool = false,
            breakTime: TimeInterval = 600,
            srsubjectsDeleteButton: Bool = true,
            srsubjectsDeleteConfirmation: Bool = true,
            liveActivity: Bool = false,
            sharedSubjects: Bool = true,
            subjectsDeleteButton: Bool = true,
            subjectsDeleteConfirmation: Bool = true,
            scheduleNotifications: Bool = true,
            todosDeleteConfirmation: Bool = true,
            todosDeleteButton: Bool = true
        ) {
            self.theme = theme
            self.accentColor = accentColor
            self.swipeActions = swipeActions
            self.editButton = editButton
            self.breakTime = breakTime
            self.srsubjectsDeleteButton = srsubjectsDeleteButton
            self.srsubjectsDeleteConfirmation = srsubjectsDeleteConfirmation
            self.liveActivity = liveActivity
            self.sharedSubjects = sharedSubjects
            self.subjectsDeleteButton = subjectsDeleteButton
            self.subjectsDeleteConfirmation = subjectsDeleteConfirmation
            self.scheduleNotifications = scheduleNotifications
            self.todosDeleteConfirmation = todosDeleteConfirmation
            self.todosDeleteButton = todosDeleteButton
        }
    }

}
