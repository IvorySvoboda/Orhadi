//
//  SubjectsDataSettingsViewModel.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 23/10/25.
//

import UIKit
import SwiftData
import Observation

extension SubjectsDataSettingsView {
    @Observable class ViewModel {
        var container: ModelContainer
        var context: ModelContext?
        var subjects: [Subject] = []
        var showDeleteConfirmation: Bool = false
        var showErrorMessage: Bool = false
        var errorMessage: String = ""
        /// Exporter
        var subjectsExportItem: DataTransferable?
        var showSubjectsFileExporter: Bool = false
        /// Importer
        var showSubjectsImportAlert: Bool = false
        var showSubjectsFileImporter: Bool = false
        var importedURL: URL?

        var allSubjects: Int {
            subjects.filter({ !$0.isRecess }).count
        }

        var allRecess: Int {
            subjects.filter({ $0.isRecess }).count
        }

        init(container: ModelContainer = createContainer()) {
            self.container = container
        }

        func fetchSubjects() {
            guard let context else { return }
            do {
                let descriptor = FetchDescriptor<Subject>(predicate: #Predicate {
                    !$0.isSubjectDeleted
                })
                subjects = try context.fetch(descriptor)
            } catch {
                print(error.localizedDescription)
            }
        }

        func deleteAllSubjects() throws {
            do {
                let context = ModelContext(container)

                let subjects = try context.fetch(FetchDescriptor<Subject>(predicate: #Predicate<Subject> {
                    !$0.isSubjectDeleted
                }))

                for subject in subjects {
                    subject.isSubjectDeleted = true
                    subject.deletedAt = .now
                }

                try context.save()

                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } catch {
                errorMessage = error.localizedDescription
                showErrorMessage.toggle()
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                throw error
            }
        }

        /// Exporter
        func exportSubjects() throws {
            do {
                let context = ModelContext(container)

                let descriptor = FetchDescriptor<Subject>(predicate: #Predicate<Subject> {
                    !$0.isSubjectDeleted
                })

                let allObjects = try context.fetch(descriptor)
                let data = try JSONEncoder().encode(allObjects)
                let exportItem = DataTransferable(data: data)

                subjectsExportItem = exportItem
                showSubjectsFileExporter = true

                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } catch {
                errorMessage = error.localizedDescription
                showErrorMessage.toggle()
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                throw error
            }
        }

        /// Importer
        func importSubjects() throws {
            guard let url = importedURL else { return }
            let isInBundle = url.path.contains(Bundle.main.bundlePath)
            guard url.startAccessingSecurityScopedResource() || isInBundle else { return }
            defer { if !isInBundle { url.stopAccessingSecurityScopedResource() } }
            do {
                let context = ModelContext(container)

                let data = try Data(contentsOf: url)
                let importedSubjects = try JSONDecoder().decode(
                    [Subject].self, from: data)

                var deletedSubjects = try context.fetch(FetchDescriptor<Subject>(predicate: #Predicate {
                    $0.isSubjectDeleted
                }))

                let existingSubjects = try context.fetch(FetchDescriptor<Subject>(predicate: #Predicate<Subject> {
                    !$0.isSubjectDeleted
                }))

                for subject in existingSubjects {
                    subject.isSubjectDeleted = true
                    subject.deletedAt = .now

                    deletedSubjects.append(subject)
                }

                for subject in importedSubjects {
                    var teacher: Teacher?

                    if let subjectTeacher = subject.teacher {
                        let existingTeacher = try context.fetch(FetchDescriptor<Teacher>(
                            predicate: #Predicate { $0.name == subjectTeacher.name }
                        )).first

                        if let existingTeacher {
                            teacher = existingTeacher
                        } else {
                            teacher = Teacher(
                                name: subjectTeacher.name,
                                email: subjectTeacher.email
                            )
                        }
                    }

                    if let matchInTrash = deletedSubjects.first(where: {
                        $0.name == subject.name &&
                        Calendar.current.isDate($0.startTime, equalTo: subject.startTime, toGranularity: .minute) &&
                        Calendar.current.isDate($0.endTime, equalTo: subject.endTime, toGranularity: .minute) &&
                        Calendar.current.isDate($0.schedule, equalTo: subject.schedule, toGranularity: .minute) &&
                        $0.isRecess == subject.isRecess &&
                        $0.teacher == teacher &&
                        $0.place == subject.place
                    }) {
                        matchInTrash.isSubjectDeleted = false
                        matchInTrash.deletedAt = nil
                    } else {
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
                }

                try context.save()

                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } catch {
                errorMessage = error.localizedDescription
                showErrorMessage.toggle()
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                throw error
            }
        }
    }
}
