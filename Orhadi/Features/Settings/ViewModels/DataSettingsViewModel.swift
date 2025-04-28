//
//  DataSettingsViewModel.swift
//  Orhadi
//
//  Created by Zyvoxi . on 28/04/25.
//

import SwiftData
import SwiftUI

@Observable class DataSettingsViewModel {
    // MARK: - Properties

    var showEraseDataAlert: Bool = false

    // MARK: - Actions

    func eraseAllData() {
        Task.detached(priority: .background) {
            do {
                let context = try createContext()

                let teachers = try context.fetch(FetchDescriptor<Teacher>())
                let subjects = try context.fetch(FetchDescriptor<Subject>())
                let todos = try context.fetch(FetchDescriptor<ToDo>())
                let studies = try context.fetch(FetchDescriptor<SRStudy>())
                let users = try context.fetch(FetchDescriptor<UserProfile>())
                let achievements = try context.fetch(FetchDescriptor<Achievement>())
                let settings = try context.fetch(FetchDescriptor<Settings>())

                for teacher in teachers { context.delete(teacher) }
                for subject in subjects { context.delete(subject) }
                for todo in todos { context.delete(todo) }
                for study in studies { context.delete(study) }
                for user in users { context.delete(user) }
                for achievement in achievements { context.delete(achievement) }
                for setting in settings { context.delete(setting) }

                context.insert(UserProfile())
                context.insert(Settings())

                try context.save()

                GameManager(context: context).setupAchievementsIfNeeded()

                await UINotificationFeedbackGenerator().notificationOccurred(.success)
            } catch {
                print(error.localizedDescription)
                await UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }
}
