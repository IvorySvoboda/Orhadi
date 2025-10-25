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
        var container: ModelContainer
        var onCompletion: (() -> Void)?
        var showEraseDataAlert: Bool = false
        var showErrorMessage: Bool = false
        var errorMessage: String = ""

        init(container: ModelContainer = createContainer()) {
            self.container = container
        }

        func handleErrorMessageChange() {
            if !errorMessage.isEmpty {
                showErrorMessage = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.errorMessage = ""
                }
            }
        }

        func eraseAllData() {
            Task.detached(priority: .background) {
                defer { self.onCompletion?() }
                do {
                    let context = ModelContext(self.container)

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

                    await UINotificationFeedbackGenerator().notificationOccurred(.success)
                } catch {
                    await MainActor.run {
                        self.errorMessage = error.localizedDescription
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                    }
                }
            }
        }
    }
}
