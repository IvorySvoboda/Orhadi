//
//  Settings.swift
//  Orhadi
//
//  Created by Zyvoxi . on 29/04/25.
//

import SwiftData
import Foundation

extension OrhadiSchemaV1 {
    @Model
    class Settings {
        /// App
        var theme: Theme

        /// Study Routine
        var breakTime: TimeInterval
        var studyGoal: TimeInterval
        var studyDeleteConfirmation: Bool

        /// Subjects
        var subjectsDeleteConfirmation: Bool

        /// ToDos
        var scheduleNotifications: Bool
        var todosDeleteConfirmation: Bool

        init(
            theme: Theme = .auto,
            breakTime: TimeInterval = 600,
            studyGoal: TimeInterval = 3600,
            studyDeleteConfirmation: Bool = true,
            subjectsDeleteConfirmation: Bool = true,
            scheduleNotifications: Bool = true,
            todosDeleteConfirmation: Bool = true,
        ) {
            self.theme = theme
            self.breakTime = breakTime
            self.studyGoal = studyGoal
            self.studyDeleteConfirmation = studyDeleteConfirmation
            self.subjectsDeleteConfirmation = subjectsDeleteConfirmation
            self.scheduleNotifications = scheduleNotifications
            self.todosDeleteConfirmation = todosDeleteConfirmation
        }
    }
}
