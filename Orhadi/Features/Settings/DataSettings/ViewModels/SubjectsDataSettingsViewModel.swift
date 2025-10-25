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
        var onCompletion: (() -> Void)?
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
            debugPrint("Subjects Data Settings: fetching...")
            do {
                let descriptor = FetchDescriptor<Subject>(predicate: #Predicate {
                    !$0.isSubjectDeleted
                })
                subjects = try context.fetch(descriptor)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }

        func handleErrorMessageChange() {
            if !errorMessage.isEmpty {
                showErrorMessage = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.errorMessage = ""
                }
            }
        }

        func deleteAllSubjects() {
            Task.detached(priority: .background) {
                defer { self.onCompletion?() }
                do {
                    let context = ModelContext(self.container)

                    let subjects = try context.fetch(FetchDescriptor<Subject>(predicate: #Predicate<Subject> {
                        !$0.isSubjectDeleted
                    }))

                    for subject in subjects {
                        subject.isSubjectDeleted = true
                        subject.deletedAt = .now
                    }

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

        /// Exporter
        func exportSubjects() {
            Task.detached(priority: .background) {
                defer { self.onCompletion?() }
                do {
                    let context = ModelContext(self.container)

                    let descriptor = FetchDescriptor<Subject>(predicate: #Predicate<Subject> {
                        !$0.isSubjectDeleted
                    })

                    let allObjects = try context.fetch(descriptor)
                    let data = try JSONEncoder().encode(allObjects)
                    let exportItem = DataTransferable(data: data)

                    await UINotificationFeedbackGenerator().notificationOccurred(.success)

                    await MainActor.run {
                        self.subjectsExportItem = exportItem
                        self.showSubjectsFileExporter = true
                    }
                } catch {
                    await MainActor.run {
                        self.errorMessage = error.localizedDescription
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                    }
                }
            }
        }

        /// Importer
        func importSubject() {
            guard let url = importedURL else { return }
            Task.detached(priority: .background) {
                guard url.startAccessingSecurityScopedResource() else { return }
                defer {
                    url.stopAccessingSecurityScopedResource()
                    self.onCompletion?()
                }
                do {
                    let context = ModelContext(self.container)

                    let data = try Data(contentsOf: url)
                    let importedSubjects = try JSONDecoder().decode(
                        [Subject].self, from: data)

                    var deletedSubjects = try context.fetch(FetchDescriptor<Subject>(predicate: #Predicate<Subject> {
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

                    await MainActor.run {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }
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
