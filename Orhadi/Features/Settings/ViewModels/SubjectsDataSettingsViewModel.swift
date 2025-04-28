//
//  SubjectsDataSettingsViewModel.swift
//  Orhadi
//
//  Created by Zyvoxi . on 28/04/25.
//

import SwiftData
import SwiftUI
import Observation

@Observable class SubjectsDataSettingsViewModel {
    // MARK: - Properties

    var showDeleteConfirmation: Bool = false

    /// Exporter
    var subjectsExportItem: SubjectTransferable?
    var showSubjectsFileExporter: Bool = false

    /// Importer
    var showSubjectsImportAlert: Bool = false
    var showSubjectsFileImporter: Bool = false
    var importedURL: URL?

    // MARK: - Computed Properties

    var subjects: [Subject]? {
        let context = try! createContext()
        return try? context.fetch(FetchDescriptor<Subject>())
    }

    var allSubjects: Int {
        (subjects?.filter({ !$0.isRecess }) ?? []).count
    }

    var allRecess: Int {
        (subjects?.filter({ $0.isRecess }) ?? []).count
    }

    // MARK: - Actions

    /// Delete
    func deleteAllSubjects() {
        Task.detached(priority: .background) {
            do {
                let context = try createContext()

                let subjects = try context.fetch(FetchDescriptor<Subject>())

                for subject in subjects {
                    context.delete(subject)
                }

                try context.save()

                await UINotificationFeedbackGenerator().notificationOccurred(.success)
            } catch {
                print(error.localizedDescription)
                await UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }

    /// Exporter
    func exportSubjects() {
        Task.detached(priority: .background) {
            do {
                let context = try createContext()

                let descriptor = FetchDescriptor<Subject>()

                let allObjects = try context.fetch(descriptor)
                let exportItem = SubjectTransferable(subjects: allObjects)

                await UINotificationFeedbackGenerator().notificationOccurred(.success)

                await MainActor.run {
                    self.subjectsExportItem = exportItem
                    self.showSubjectsFileExporter = true
                }
            } catch {
                print(error.localizedDescription)
                await UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }

    /// Importer
    func importSubject() {
        guard let url = importedURL else { return }
        Task.detached(priority: .background) {
            do {
                guard url.startAccessingSecurityScopedResource() else { return }

                let context = try createContext()

                let existingSubjects = try context.fetch(FetchDescriptor<Subject>())
                for subject in existingSubjects { context.delete(subject) }

                let data = try Data(contentsOf: url)
                let allSubjects = try JSONDecoder().decode(
                    [Subject].self, from: data)

                for subject in allSubjects {
                    var teacher: Teacher? = nil

                    if let subjectTeacher = subject.teacher {
                        let existingTeacher = try context.fetch(FetchDescriptor<Teacher>(
                            predicate: #Predicate { $0.name == subjectTeacher.name }
                        )).first

                        if let existingTeacher {
                            teacher = existingTeacher
                        } else {
                            teacher = subjectTeacher
                        }
                    }

                    context.insert(
                        Subject(
                            name: subject.name,
                            teacher: teacher,
                            schedule: subject.schedule,
                            startTime: subject.startTime,
                            endTime: subject.endTime,
                            place: subject.place,
                            isRecess: subject.isRecess
                        )
                    )
                }

                try context.save()

                url.stopAccessingSecurityScopedResource()

                await UINotificationFeedbackGenerator().notificationOccurred(.success)
            } catch {
                print(error.localizedDescription)
                await UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }

}
