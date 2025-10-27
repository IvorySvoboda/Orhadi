//
//  DataTests.swift
//  OrhadiTests
//
//  Created by Ivory Svoboda on 26/10/25.
//

import Foundation
import SwiftData
import Testing
@testable import Orhadi

@Suite("Data Tests", .tags(.viewModelsTests)) struct DataTests {
    @Suite("Data Settings Tests") @MainActor struct DataSettingsTests {
        @Test func `Erase All Data Test`() throws {
            let testingContainer = createContainer(testing: true)
            let context = ModelContext(testingContainer)

            try SampleDataManager.shared.insertSampleData(in: context)

            let viewModel = DataSettingsView.ViewModel(container: testingContainer)
            try viewModel.eraseAllData()

            let subjects = try context.fetch(FetchDescriptor<Subject>())
            let teachers = try context.fetch(FetchDescriptor<Teacher>())
            let todos = try context.fetch(FetchDescriptor<ToDo>())
            let studies = try context.fetch(FetchDescriptor<SRStudy>())
            let settings = try context.fetch(FetchDescriptor<Settings>())

            #expect(subjects.isEmpty)
            #expect(teachers.isEmpty)
            #expect(todos.isEmpty)
            #expect(studies.isEmpty)
            #expect(settings.count == 1)
        }
    }

    @Suite("Subjects Data Settings Tests") @MainActor struct SubjectsDataSettingsTests {
        @Test func `Delete All Subjects Test`() throws {
            let testingContainer = createContainer(testing: true)
            let context = ModelContext(testingContainer)

            try SampleDataManager.shared.insertSampleData(in: context)

            let viewModel = SubjectsDataSettingsView.ViewModel(container: testingContainer)
            try viewModel.deleteAllSubjects()

            let subjects = try context.fetch(FetchDescriptor<Subject>(predicate: #Predicate { !$0.isSubjectDeleted }))
            let deletedSubjects = try context.fetch(FetchDescriptor<Subject>(predicate: #Predicate { $0.isSubjectDeleted }))
            let teachers = try context.fetch(FetchDescriptor<Teacher>())

            #expect(viewModel.errorMessage.isEmpty)
            #expect(subjects.isEmpty)
            #expect(deletedSubjects.count == SampleDataManager.shared.expectedSubjectsCount)
            #expect(!teachers.isEmpty)
        }

        @Test func `Subjects Export Test`() throws {
            let testingContainer = createContainer(testing: true)
            let context = ModelContext(testingContainer)

            try SampleDataManager.shared.insertSampleData(in: context)

            let viewModel = SubjectsDataSettingsView.ViewModel(container: testingContainer)
            try viewModel.exportSubjects()

            let subjectsExportItem = try #require(viewModel.subjectsExportItem)
            let subjects = try JSONDecoder().decode([Subject].self, from: subjectsExportItem.data)
            #expect(subjects.count == SampleDataManager.shared.expectedSubjectsCount)
        }

        @Test func `Subjects Import Test`() throws {
            let testingContainer = createContainer(testing: true)
            let context = ModelContext(testingContainer)

            let subjectsPath = try #require(Bundle.main.path(forResource: "Subjects", ofType: "json"))
            let subjectsURL = URL(filePath: subjectsPath)

            let viewModel = SubjectsDataSettingsView.ViewModel(container: testingContainer)
            viewModel.importedURL = subjectsURL
            try viewModel.importSubjects()

            let subjects = try context.fetch(FetchDescriptor<Subject>())
            #expect(subjects.count == SampleDataManager.shared.expectedSubjectsCount)
        }
    }

    @Suite("To-Dos Data Settings Tests") @MainActor struct ToDosDataSettingsTests {
        @Test func `Delete All To-Dos Test`() throws {
            let testingContainer = createContainer(testing: true)
            let context = ModelContext(testingContainer)

            try SampleDataManager.shared.insertSampleData(in: context)

            let viewModel = ToDosDataSettingsView.ViewModel(container: testingContainer)
            try viewModel.deleteAllToDos()

            let todos = try context.fetch(FetchDescriptor<ToDo>(predicate: #Predicate { !$0.isToDoDeleted }))
            let deletedToDos = try context.fetch(FetchDescriptor<ToDo>(predicate: #Predicate { $0.isToDoDeleted }))
            #expect(todos.isEmpty)
            #expect(deletedToDos.count == SampleDataManager.shared.expectedToDosCount)
        }

        @Test func `To-Dos Export Test`() throws {
            let testingContainer = createContainer(testing: true)
            let context = ModelContext(testingContainer)

            try SampleDataManager.shared.insertSampleData(in: context)

            let viewModel = ToDosDataSettingsView.ViewModel(container: testingContainer)
            try viewModel.exportToDos()

            let todosExportItem = try #require(viewModel.todosExportItem)
            let todos = try JSONDecoder().decode([ToDo].self, from: todosExportItem.data)
            #expect(todos.count == SampleDataManager.shared.expectedToDosCount)
        }

        @Test func `To-Dos Import Test`() throws {
            let testingContainer = createContainer(testing: true)
            let context = ModelContext(testingContainer)

            let todosPath = try #require(Bundle.main.path(forResource: "ToDos", ofType: "json"))
            let todosURL = URL(filePath: todosPath)

            let viewModel = ToDosDataSettingsView.ViewModel(container: testingContainer)
            viewModel.importedURL = todosURL
            try viewModel.importToDos()

            let todos = try context.fetch(FetchDescriptor<ToDo>())
            #expect(todos.count == SampleDataManager.shared.expectedToDosCount)
        }
    }

    @Suite("Study Routine Data Settings Tests") @MainActor struct StudyRoutineDataSettingsTests {
        @Test func `Delete All Studies Test`() throws {
            let testingContainer = createContainer(testing: true)
            let context = ModelContext(testingContainer)

            try SampleDataManager.shared.insertSampleData(in: context)

            let viewModel = SRDataSettingsView.ViewModel(container: testingContainer)
            try viewModel.deleteAllStudies()

            let studies = try context.fetch(FetchDescriptor<SRStudy>(predicate: #Predicate { !$0.isStudyDeleted }))
            let deletedStudies = try context.fetch(FetchDescriptor<SRStudy>(predicate: #Predicate { $0.isStudyDeleted }))
            #expect(studies.isEmpty)
            #expect(deletedStudies.count == SampleDataManager.shared.expectedStudiesCount)
        }

        @Test func `Studies Export Test`() throws {
            let testingContainer = createContainer(testing: true)
            let context = ModelContext(testingContainer)

            try SampleDataManager.shared.insertSampleData(in: context)

            let viewModel = SRDataSettingsView.ViewModel(container: testingContainer)
            try viewModel.exportSR()

            let studiesExportItem = try #require(viewModel.srExportItem)
            let studies = try JSONDecoder().decode([SRStudy].self, from: studiesExportItem.data)
            #expect(studies.count == SampleDataManager.shared.expectedStudiesCount)
        }

        @Test func `Studies Import Test`() throws {
            let testingContainer = createContainer(testing: true)
            let context = ModelContext(testingContainer)

            let studiesPath = try #require(Bundle.main.path(forResource: "StudyRoutine", ofType: "json"))
            let studiesURL = URL(filePath: studiesPath)

            let viewModel = SRDataSettingsView.ViewModel(container: testingContainer)
            viewModel.importedURL = studiesURL
            try viewModel.importSR()

            let studies = try context.fetch(FetchDescriptor<SRStudy>())
            #expect(studies.count == SampleDataManager.shared.expectedStudiesCount)
        }
    }
}
