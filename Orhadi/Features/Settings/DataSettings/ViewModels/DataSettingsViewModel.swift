//
//  DataSettingsViewModel.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 23/10/25.
//

import UIKit
import SwiftData
import Observation

extension DataSettingsView {
    @Observable class ViewModel {
        // MARK: - Properties

        private let dataManager: DataManager
        var showEraseDataAlert: Bool = false
        var showErrorMessage: Bool = false
        var errorMessage: String = ""

        // MARK: - INIT

        init(dataManager: DataManager) {
            self.dataManager = dataManager
        }

        // MARK: - Functions

        func eraseAllData() throws {
            do {
                let context = ModelContext(dataManager.container)

                let teachers = try context.fetch(FetchDescriptor<Teacher>())
                let subjects = try context.fetch(FetchDescriptor<Subject>())
                let todos = try context.fetch(FetchDescriptor<ToDo>())
                let studies = try context.fetch(FetchDescriptor<SRStudy>())
                let settings = try context.fetch(FetchDescriptor<Settings>())

                for teacher in teachers { context.delete(teacher) }

                try context.save()

                for subject in subjects { context.delete(subject) }
                for todo in todos { context.delete(todo) }
                for study in studies { context.delete(study) }
                for setting in settings { context.delete(setting) }

                context.insert(Settings())

                try context.save()

                FeedbackGenerator().notificationOccurred(.success)
            } catch {
                errorMessage = error.localizedDescription
                showErrorMessage.toggle()
                FeedbackGenerator().notificationOccurred(.error)
                throw error /// Useful for unit tests.
            }
        }
    }
}
