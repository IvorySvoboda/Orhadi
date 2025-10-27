//
//  SampleDataManager.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 26/10/25.
//

import Foundation
import SwiftData

class SampleDataManager {

    static let shared = SampleDataManager()

    let expectedSubjectsCount: Int
    let expectedToDosCount: Int
    let expectedStudiesCount: Int

    let subjects: [Subject]
    let todos: [ToDo]
    let studies: [SRStudy]

    private init() {
        do {
            guard
                let subjectsPath = Bundle.main.path(forResource: "Subjects", ofType: "json"),
                let todosPath = Bundle.main.path(forResource: "ToDos", ofType: "json"),
                let studiesPath = Bundle.main.path(forResource: "StudyRoutine", ofType: "json")
            else {
                throw SampleDataManagerError.fileNotFound
            }

            let subjects = try JSONDecoder().decode([Subject].self, from: Data(contentsOf: URL(filePath: subjectsPath)))
            let todos = try JSONDecoder().decode([ToDo].self, from: Data(contentsOf: URL(filePath: todosPath)))
            let studies = try JSONDecoder().decode([SRStudy].self, from: Data(contentsOf: URL(filePath: studiesPath)))

            self.expectedSubjectsCount = subjects.count
            self.expectedToDosCount = todos.count
            self.expectedStudiesCount = studies.count

            self.subjects = subjects
            self.todos = todos
            self.studies = studies
        } catch {
            fatalError("Failed to load sample data: \(error.localizedDescription)")
        }
    }

    @MainActor
    func insertSampleData(in context: ModelContext) throws {
        do {
            for subject in subjects {
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

            for todo in todos {
                context.insert(
                    ToDo(
                        title: todo.title,
                        info: todo.info,
                        dueDate: todo.dueDate,
                        withHour: todo.withHour,
                        createdAt: todo.createdAt,
                        isCompleted: todo.isCompleted,
                        completedAt: todo.completedAt,
                        priority: todo.priority,
                        isArchived: todo.isArchived)
                )
            }

            for study in studies {
                context.insert(
                    SRStudy(
                        name: study.name,
                        studyDay: study.studyDay,
                        studyTime: study.studyTime)
                )
            }

            context.insert(Settings())

            try context.save()
        } catch {
            throw SampleDataManagerError.insertionFailed(error)
        }
    }

    enum SampleDataManagerError: Error {
        case fileNotFound
        case insertionFailed(Error)
    }
}
