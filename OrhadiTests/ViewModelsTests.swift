//
//  ViewModelsTests.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 27/10/25.
//

import Foundation
import Testing
import SwiftData
@testable import Orhadi

@Suite("ViewModels Tests", .tags(.viewModels))
struct ViewModelsTests {
    @Suite("Data Settings Tests", .tags(.subjects, .studies, .todos))
    @MainActor struct DataSettingsTests {
        @Test func `Erase All Data Test`() throws {
            let dataManager = DataManager.shared
            dataManager.reset() /// `reset()` Changes the manager container to a brand new `inMemoryOnly` container.

            let vm = DataSettingsView.ViewModel(dataManager: dataManager)
            try vm.eraseAllData()

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

    @Suite("Subjects Data Settings Tests", .tags(.subjects))
    @MainActor struct SubjectsDataSettingsTests {
        @Test func `Delete All Subjects Test`() throws {
            let dataManager = DataManager.shared
            dataManager.reset() /// `reset()` Changes the manager container to a brand new `inMemoryOnly` container.

            let vm = SubjectsDataSettingsView.ViewModel(dataManager: dataManager)
            try vm.deleteAllSubjects()

            let subjects = dataManager.fetchSubjects(predicate: #Predicate { !$0.isSubjectDeleted })
            let deletedSubjects = dataManager.fetchSubjects(predicate: #Predicate { $0.isSubjectDeleted })
            let teachers = dataManager.fetchTeachers()

            #expect(vm.errorMessage.isEmpty)
            #expect(subjects.isEmpty)
            #expect(deletedSubjects.count == SampleDataManager.shared.expectedSubjectsCount)
            #expect(!teachers.isEmpty)
        }

        @Test func `Subjects Export Test`() throws {
            let dataManager = DataManager.shared
            dataManager.reset() /// `reset()` Changes the manager container to a brand new `inMemoryOnly` container.

            let vm = SubjectsDataSettingsView.ViewModel(dataManager: dataManager)
            try vm.exportSubjects()

            let subjectsExportItem = try #require(vm.subjectsExportItem)
            let subjects = try JSONDecoder().decode([Subject].self, from: subjectsExportItem.data)
            #expect(subjects.count == SampleDataManager.shared.expectedSubjectsCount)
        }

        @Test func `Subjects Import Test`() throws {
            let dataManager = DataManager.shared
            dataManager.reset(withSampleData: false) /// `reset()` Changes the manager container to a brand new `inMemoryOnly` container.

            let subjectsPath = try #require(Bundle.main.path(forResource: "Subjects", ofType: "json"))
            let subjectsURL = URL(filePath: subjectsPath)

            let vm = SubjectsDataSettingsView.ViewModel(dataManager: dataManager)
            vm.importedURL = subjectsURL
            try vm.importSubjects()

            let subjects = dataManager.fetchSubjects()

            #expect(subjects.count == SampleDataManager.shared.expectedSubjectsCount)
        }
    }

    @Suite("To-Dos Data Settings Tests", .tags(.todos))
    @MainActor struct ToDosDataSettingsTests {
        @Test func `Delete All To-Dos Test`() throws {
            let dataManager = DataManager.shared
            dataManager.reset() /// `reset()` Changes the manager container to a brand new `inMemoryOnly` container.

            let vm = ToDosDataSettingsView.ViewModel(dataManager: dataManager)
            try vm.deleteAllToDos()

            let todos = dataManager.fetchToDos(predicate: #Predicate { !$0.isToDoDeleted })
            let deletedToDos = dataManager.fetchToDos(predicate: #Predicate { $0.isToDoDeleted })
            #expect(todos.isEmpty)
            #expect(deletedToDos.count == SampleDataManager.shared.expectedToDosCount)
        }

        @Test func `To-Dos Export Test`() throws {
            let dataManager = DataManager.shared
            dataManager.reset() /// `reset()` Changes the manager container to a brand new `inMemoryOnly` container.

            let vm = ToDosDataSettingsView.ViewModel(dataManager: dataManager)
            try vm.exportToDos()

            let todosExportItem = try #require(vm.todosExportItem)
            let todos = try JSONDecoder().decode([ToDo].self, from: todosExportItem.data)
            #expect(todos.count == SampleDataManager.shared.expectedToDosCount)
        }

        @Test func `To-Dos Import Test`() throws {
            let dataManager = DataManager.shared
            dataManager.reset(withSampleData: false) /// `reset()` Changes the manager container to a brand new `inMemoryOnly` container.

            let todosPath = try #require(Bundle.main.path(forResource: "ToDos", ofType: "json"))
            let todosURL = URL(filePath: todosPath)

            let vm = ToDosDataSettingsView.ViewModel(dataManager: dataManager)
            vm.importedURL = todosURL
            try vm.importToDos()

            let todos = dataManager.fetchToDos()
            #expect(todos.count == SampleDataManager.shared.expectedToDosCount)
        }
    }

    @Suite("Study Routine Data Settings Tests", .tags(.studies))
    @MainActor struct StudyRoutineDataSettingsTests {
        @Test func `Delete All Studies Test`() throws {
            let dataManager = DataManager.shared
            dataManager.reset() /// `reset()` Changes the manager container to a brand new `inMemoryOnly` container.

            let vm = SRDataSettingsView.ViewModel(dataManager: dataManager)
            try vm.deleteAllStudies()

            let studies = dataManager.fetchStudies(predicate: #Predicate { !$0.isStudyDeleted })
            let deletedStudies = dataManager.fetchStudies(predicate: #Predicate { $0.isStudyDeleted })
            #expect(studies.isEmpty)
            #expect(deletedStudies.count == SampleDataManager.shared.expectedStudiesCount)
        }

        @Test func `Studies Export Test`() throws {
            let dataManager = DataManager.shared
            dataManager.reset() /// `reset()` Changes the manager container to a brand new `inMemoryOnly` container.

            let vm = SRDataSettingsView.ViewModel(dataManager: dataManager)
            try vm.exportSR()

            let studiesExportItem = try #require(vm.srExportItem)
            let studies = try JSONDecoder().decode([SRStudy].self, from: studiesExportItem.data)
            #expect(studies.count == SampleDataManager.shared.expectedStudiesCount)
        }

        @Test func `Studies Import Test`() throws {
            let dataManager = DataManager.shared
            dataManager.reset(withSampleData: false) /// `reset()` Changes the manager container to a brand new `inMemoryOnly` container.

            let studiesPath = try #require(Bundle.main.path(forResource: "StudyRoutine", ofType: "json"))
            let studiesURL = URL(filePath: studiesPath)

            let vm = SRDataSettingsView.ViewModel(dataManager: dataManager)
            vm.importedURL = studiesURL
            try vm.importSR()

            let studies = dataManager.fetchStudies()
            #expect(studies.count == SampleDataManager.shared.expectedStudiesCount)
        }
    }

    @Suite("Subjects ViewModels Tests", .tags(.subjects))
    @MainActor struct SubjectsViewModelsTests {
        @Test func `Subjects ViewModel – Fetch & Scroll Behavior Tests`() throws {
            let dataManager = DataManager.shared
            dataManager.reset() /// `reset()` Changes the manager container to a brand new `inMemoryOnly` container.

            let vm = SubjectsView.ViewModel(dataManager: dataManager)
            #expect(vm.subjects.count == SampleDataManager.shared.expectedSubjectsCount)

            vm.handleScrollGeoChange(-150)
            #expect(!vm.showTitle)
            #expect(!vm.showSelectedWeekday)
            #expect(!vm.hideOverlay)

            vm.handleScrollGeoChange(-100)
            #expect(vm.showTitle)
            #expect(!vm.showSelectedWeekday)
            #expect(!vm.hideOverlay)

            vm.handleScrollGeoChange(0)
            #expect(vm.showTitle)
            #expect(vm.showSelectedWeekday)
            #expect(!vm.hideOverlay)

            vm.handleScrollGeoChange(-300)
            #expect(!vm.showTitle)
            #expect(!vm.showSelectedWeekday)
            #expect(vm.hideOverlay)
        }

        @Test func `Subjects Sheet ViewModel – Conflict, Insert & Edit Tests`() throws {
            let dataManager = DataManager.shared
            dataManager.reset(withSampleData: false) /// `reset()` Changes the manager container to a brand new `inMemoryOnly` container.

            var vm = SubjectSheetView.ViewModel(subject: Subject(isRecess: false), isNew: true, dataManager: dataManager)
            vm.draftSubject.name = "TestSubject"
            #expect(vm.canSave)
            try vm.trySave()

            var subjects = dataManager.fetchSubjects()
            #expect(subjects.count == 1)

            let testSubject = try #require(subjects.filter({ $0.name == "TestSubject" }).first)
            vm = SubjectSheetView.ViewModel(subject: testSubject, isNew: false, dataManager: dataManager)
            vm.draftSubject.name = "EditedTestSubject"
            #expect(vm.canSave)
            try vm.trySave()

            subjects = dataManager.fetchSubjects()
            #expect(subjects.count == 1)
            #expect(subjects.filter({ $0.name == "EditedTestSubject" }).first != nil)

            vm = SubjectSheetView.ViewModel(subject: Subject(isRecess: false), isNew: true, dataManager: dataManager)
            vm.draftSubject.name = "ConflictingTestSubject"
            #expect(!vm.canSave)
        }
    }

    @Suite("To-Dos ViewModels Tests", .tags(.todos))
    @MainActor struct ToDosViewModelsTests {
        @Test func `To-Dos ViewModel – Fetch & Scroll Behavior Tests`() throws {
            let dataManager = DataManager.shared
            dataManager.reset() /// `reset()` Changes the manager container to a brand new `inMemoryOnly` container.

            let vm = ToDosView.ViewModel(dataManager: dataManager)
            #expect(vm.pendingToDos.count + vm.completedToDos.count == SampleDataManager.shared.expectedToDosCount)

            vm.handleScrollGeoChange(-150)
            #expect(!vm.showTitle)
            #expect(!vm.showSelectedSection)
            #expect(!vm.hideOverlay)

            vm.handleScrollGeoChange(-100)
            #expect(vm.showTitle)
            #expect(!vm.showSelectedSection)
            #expect(!vm.hideOverlay)

            vm.handleScrollGeoChange(0)
            #expect(vm.showTitle)
            #expect(vm.showSelectedSection)
            #expect(!vm.hideOverlay)

            vm.handleScrollGeoChange(-300)
            #expect(!vm.showTitle)
            #expect(!vm.showSelectedSection)
            #expect(vm.hideOverlay)
        }

        @Test func `To-Dos Sheet ViewModel – Insert & Edit Tests`() throws {
            let dataManager = DataManager.shared
            dataManager.reset(withSampleData: false) /// `reset()` Changes the manager container to a brand new `inMemoryOnly` container.

            var vm = ToDoSheetView.ViewModel(todo: ToDo(), isNew: true, dataManager: dataManager)
            vm.draftToDo.title = "TestToDo"
            try vm.trySave()

            var todos = dataManager.fetchToDos()
            #expect(todos.count == 1)

            let testToDo = try #require(todos.filter({ $0.title == "TestToDo" }).first)
            vm = ToDoSheetView.ViewModel(todo: testToDo, isNew: false, dataManager: dataManager)
            vm.draftToDo.title = "EditedTestToDo"
            try vm.trySave()

            todos = dataManager.fetchToDos()
            #expect(todos.count == 1)
            #expect(todos.filter({ $0.title == "EditedTestToDo" }).first != nil)
        }
    }

    @Suite("Study Routine ViewModels Tests", .tags(.studies))
    @MainActor struct StudyRoutineViewModelsTests {
        @Test func `Study Routine ViewModel – Fetch & Scroll Behavior Tests`() throws {
            let dataManager = DataManager.shared
            dataManager.reset() /// `reset()` Changes the manager container to a brand new `inMemoryOnly` container.

            let vm = SRView.ViewModel(dataManager: dataManager)
            #expect(vm.studies.count == SampleDataManager.shared.expectedStudiesCount)

            vm.handleScrollGeoChange(-150)
            #expect(!vm.showTitle)
            #expect(!vm.showSelectedWeekday)
            #expect(!vm.hideOverlay)

            vm.handleScrollGeoChange(-100)
            #expect(vm.showTitle)
            #expect(!vm.showSelectedWeekday)
            #expect(!vm.hideOverlay)

            vm.handleScrollGeoChange(0)
            #expect(vm.showTitle)
            #expect(vm.showSelectedWeekday)
            #expect(!vm.hideOverlay)

            vm.handleScrollGeoChange(-300)
            #expect(!vm.showTitle)
            #expect(!vm.showSelectedWeekday)
            #expect(vm.hideOverlay)
        }

        @Test func `Study Routine Study Sheet ViewModel – Insert & Edit Tests`() throws {
            let dataManager = DataManager.shared
            dataManager.reset(withSampleData: false) /// `reset()` Changes the manager container to a brand new `inMemoryOnly` container.

            var vm = SRSheetView.ViewModel(study: SRStudy(), isNew: true, dataManager: dataManager)
            vm.draftStudy.name = "TestStudy"
            try vm.trySave()

            var studies = dataManager.fetchStudies()
            #expect(studies.count == 1)

            let testStudy = try #require(studies.filter({ $0.name == "TestStudy" }).first)
            vm = SRSheetView.ViewModel(study: testStudy, isNew: false, dataManager: dataManager)
            vm.draftStudy.name = "EditedTestStudy"
            try vm.trySave()

            studies = dataManager.fetchStudies()
            #expect(studies.count == 1)
            #expect(studies.filter({ $0.name == "EditedTestStudy" }).first != nil)
        }
    }
}
