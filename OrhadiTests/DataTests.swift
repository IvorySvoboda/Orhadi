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

@Suite("Data Tests", .tags(.viewModels)) struct DataTests {
    @Suite("Data Settings Tests", .tags(.subjects, .studies, .todos)) @MainActor struct DataSettingsTests {
        @Test func `Erase All Data Test`() throws {
            let dataManager = DataManager.shared
            dataManager.prepareForTests() /// `prepareForTests()` Changes the manager container to a brand new `inMemoryOnly` container.

            let viewModel = DataSettingsView.ViewModel(dataManager: dataManager)
            try viewModel.eraseAllData()

            let subjects = dataManager.fetchSubjects()
            let teachers = dataManager.fetchTeachers()
            let todos = dataManager.fetchToDos()
            let studies = dataManager.fetchStudies()
            let settings = try dataManager.context.fetch(FetchDescriptor<Settings>())

            #expect(subjects.isEmpty)
            #expect(teachers.isEmpty)
            #expect(todos.isEmpty)
            #expect(studies.isEmpty)
            #expect(settings.count == 1)
        }
    }

    @Suite("Subjects Data Settings Tests", .tags(.subjects)) @MainActor struct SubjectsDataSettingsTests {
        @Test func `Delete All Subjects Test`() throws {
            let dataManager = DataManager.shared
            dataManager.prepareForTests() /// `prepareForTests()` Changes the manager container to a brand new `inMemoryOnly` container.

            let viewModel = SubjectsDataSettingsView.ViewModel(dataManager: dataManager)
            try viewModel.deleteAllSubjects()

            let subjects = dataManager.fetchSubjects(predicate: #Predicate { !$0.isSubjectDeleted })
            let deletedSubjects = dataManager.fetchSubjects(predicate: #Predicate { $0.isSubjectDeleted })
            let teachers = dataManager.fetchTeachers()

            #expect(viewModel.errorMessage.isEmpty)
            #expect(subjects.isEmpty)
            #expect(deletedSubjects.count == SampleDataManager.shared.expectedSubjectsCount)
            #expect(!teachers.isEmpty)
        }

        @Test func `Subjects Export Test`() throws {
            let dataManager = DataManager.shared
            dataManager.prepareForTests() /// `prepareForTests()` Changes the manager container to a brand new `inMemoryOnly` container.

            let viewModel = SubjectsDataSettingsView.ViewModel(dataManager: dataManager)
            try viewModel.exportSubjects()

            let subjectsExportItem = try #require(viewModel.subjectsExportItem)
            let subjects = try JSONDecoder().decode([Subject].self, from: subjectsExportItem.data)
            #expect(subjects.count == SampleDataManager.shared.expectedSubjectsCount)
        }

        @Test func `Subjects Import Test`() throws {
            let dataManager = DataManager.shared
            dataManager.prepareForTests(withSampleData: false) /// `prepareForTests()` Changes the manager container to a brand new `inMemoryOnly` container.

            let subjectsPath = try #require(Bundle.main.path(forResource: "Subjects", ofType: "json"))
            let subjectsURL = URL(filePath: subjectsPath)

            let viewModel = SubjectsDataSettingsView.ViewModel(dataManager: dataManager)
            viewModel.importedURL = subjectsURL
            try viewModel.importSubjects()

            let subjects = dataManager.fetchSubjects()

            #expect(subjects.count == SampleDataManager.shared.expectedSubjectsCount)
        }
    }

    @Suite("To-Dos Data Settings Tests", .tags(.todos)) @MainActor struct ToDosDataSettingsTests {
        @Test func `Delete All To-Dos Test`() throws {
            let dataManager = DataManager.shared
            dataManager.prepareForTests() /// `prepareForTests()` Changes the manager container to a brand new `inMemoryOnly` container.

            let viewModel = ToDosDataSettingsView.ViewModel(dataManager: dataManager)
            try viewModel.deleteAllToDos()

            let todos = dataManager.fetchToDos(predicate: #Predicate { !$0.isToDoDeleted })
            let deletedToDos = dataManager.fetchToDos(predicate: #Predicate { $0.isToDoDeleted })
            #expect(todos.isEmpty)
            #expect(deletedToDos.count == SampleDataManager.shared.expectedToDosCount)
        }

        @Test func `To-Dos Export Test`() throws {
            let dataManager = DataManager.shared
            dataManager.prepareForTests() /// `prepareForTests()` Changes the manager container to a brand new `inMemoryOnly` container.

            let viewModel = ToDosDataSettingsView.ViewModel(dataManager: dataManager)
            try viewModel.exportToDos()

            let todosExportItem = try #require(viewModel.todosExportItem)
            let todos = try JSONDecoder().decode([ToDo].self, from: todosExportItem.data)
            #expect(todos.count == SampleDataManager.shared.expectedToDosCount)
        }

        @Test func `To-Dos Import Test`() throws {
            let dataManager = DataManager.shared
            dataManager.prepareForTests(withSampleData: false) /// `prepareForTests()` Changes the manager container to a brand new `inMemoryOnly` container.

            let todosPath = try #require(Bundle.main.path(forResource: "ToDos", ofType: "json"))
            let todosURL = URL(filePath: todosPath)

            let viewModel = ToDosDataSettingsView.ViewModel(dataManager: dataManager)
            viewModel.importedURL = todosURL
            try viewModel.importToDos()

            let todos = dataManager.fetchToDos()
            #expect(todos.count == SampleDataManager.shared.expectedToDosCount)
        }
    }

    @Suite("Study Routine Data Settings Tests", .tags(.studies)) @MainActor struct StudyRoutineDataSettingsTests {
        @Test func `Delete All Studies Test`() throws {
            let dataManager = DataManager.shared
            dataManager.prepareForTests() /// `prepareForTests()` Changes the manager container to a brand new `inMemoryOnly` container.

            let viewModel = SRDataSettingsView.ViewModel(dataManager: dataManager)
            try viewModel.deleteAllStudies()

            let studies = dataManager.fetchStudies(predicate: #Predicate { !$0.isStudyDeleted })
            let deletedStudies = dataManager.fetchStudies(predicate: #Predicate { $0.isStudyDeleted })
            #expect(studies.isEmpty)
            #expect(deletedStudies.count == SampleDataManager.shared.expectedStudiesCount)
        }

        @Test func `Studies Export Test`() throws {
            let dataManager = DataManager.shared
            dataManager.prepareForTests() /// `prepareForTests()` Changes the manager container to a brand new `inMemoryOnly` container.

            let viewModel = SRDataSettingsView.ViewModel(dataManager: dataManager)
            try viewModel.exportSR()

            let studiesExportItem = try #require(viewModel.srExportItem)
            let studies = try JSONDecoder().decode([SRStudy].self, from: studiesExportItem.data)
            #expect(studies.count == SampleDataManager.shared.expectedStudiesCount)
        }

        @Test func `Studies Import Test`() throws {
            let dataManager = DataManager.shared
            dataManager.prepareForTests(withSampleData: false) /// `prepareForTests()` Changes the manager container to a brand new `inMemoryOnly` container.

            let studiesPath = try #require(Bundle.main.path(forResource: "StudyRoutine", ofType: "json"))
            let studiesURL = URL(filePath: studiesPath)

            let viewModel = SRDataSettingsView.ViewModel(dataManager: dataManager)
            viewModel.importedURL = studiesURL
            try viewModel.importSR()

            let studies = dataManager.fetchStudies()
            #expect(studies.count == SampleDataManager.shared.expectedStudiesCount)
        }
    }
}
