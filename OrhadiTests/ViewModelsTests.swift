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

//@Suite("ViewModels Tests", .tags(.viewModels)) struct ViewModelsTests {
//    @Suite("Subjects ViewModels Tests", .tags(.subjects)) @MainActor struct SubjectsViewModelsTests {
//        @Test func `Subjects ViewModel – Fetch & Scroll Behavior Tests`() throws {
//            let testingContainer = createContainer(testing: true)
//            let context = ModelContext(testingContainer)
//
//            try SampleDataManager.shared.insertSampleData(in: context)
//
//            let viewModel = SubjectsView.ViewModel(context: context)
//            #expect(viewModel.subjects.count == SampleDataManager.shared.expectedSubjectsCount)
//
//            viewModel.handleScrollGeoChange(-150)
//            #expect(!viewModel.showTitle)
//            #expect(!viewModel.showSelectedWeekday)
//            #expect(!viewModel.hideOverlay)
//
//            viewModel.handleScrollGeoChange(-100)
//            #expect(viewModel.showTitle)
//            #expect(!viewModel.showSelectedWeekday)
//            #expect(!viewModel.hideOverlay)
//
//            viewModel.handleScrollGeoChange(0)
//            #expect(viewModel.showTitle)
//            #expect(viewModel.showSelectedWeekday)
//            #expect(!viewModel.hideOverlay)
//
//            viewModel.handleScrollGeoChange(-300)
//            #expect(!viewModel.showTitle)
//            #expect(!viewModel.showSelectedWeekday)
//            #expect(viewModel.hideOverlay)
//        }
//
//        @Test func `Subjects Sheet ViewModel – Conflict, Insert & Edit Tests`() throws {
//            let testingContainer = createContainer(testing: true)
//            let context = ModelContext(testingContainer)
//
//            var viewModel = SubjectSheetView.ViewModel(subject: Subject(isRecess: false), isNew: true, context: context)
//            viewModel.draftSubject.name = "TestSubject"
//            viewModel.trySave()
//
//            var subjects = try context.fetch(FetchDescriptor<Subject>())
//            #expect(subjects.count == 1)
//
//            let testSubject = try #require(subjects.filter({ $0.name == "TestSubject" }).first)
//            viewModel = SubjectSheetView.ViewModel(subject: testSubject, isNew: false, context: context)
//            viewModel.draftSubject.name = "EditedTestSubject"
//            viewModel.trySave()
//
//            subjects = try context.fetch(FetchDescriptor<Subject>())
//            #expect(subjects.count == 1)
//            #expect(subjects.filter({ $0.name == "EditedTestSubject" }).first != nil)
//
//            viewModel = SubjectSheetView.ViewModel(subject: Subject(isRecess: false), isNew: true, context: context)
//            viewModel.draftSubject.name = "ConflictingTestSubject"
//            viewModel.trySave()
//            #expect(viewModel.showConflictAlert)
//
//            subjects = try context.fetch(FetchDescriptor<Subject>())
//            #expect(subjects.count == 1)
//            #expect(subjects.filter({ $0.name == "ConflictingTestSubject" }).first == nil)
//        }
//    }
//
//    @Suite("To-Dos ViewModels Tests", .tags(.todos)) @MainActor struct ToDosViewModelsTests {
//        @Test func `To-Dos ViewModel – Fetch & Scroll Behavior Tests`() throws {
//            let testingContainer = createContainer(testing: true)
//            let context = ModelContext(testingContainer)
//
//            try SampleDataManager.shared.insertSampleData(in: context)
//
//            let viewModel = ToDosView.ViewModel(context: context)
//            #expect(viewModel.pendingToDos.count + viewModel.completedToDos.count == SampleDataManager.shared.expectedToDosCount)
//
//            viewModel.handleScrollGeoChange(-150)
//            #expect(!viewModel.showTitle)
//            #expect(!viewModel.showSelectedSection)
//            #expect(!viewModel.hideOverlay)
//
//            viewModel.handleScrollGeoChange(-100)
//            #expect(viewModel.showTitle)
//            #expect(!viewModel.showSelectedSection)
//            #expect(!viewModel.hideOverlay)
//
//            viewModel.handleScrollGeoChange(0)
//            #expect(viewModel.showTitle)
//            #expect(viewModel.showSelectedSection)
//            #expect(!viewModel.hideOverlay)
//
//            viewModel.handleScrollGeoChange(-300)
//            #expect(!viewModel.showTitle)
//            #expect(!viewModel.showSelectedSection)
//            #expect(viewModel.hideOverlay)
//        }
//
//        @Test func `To-Dos Sheet ViewModel – Insert & Edit Tests`() throws {
//            let testingContainer = createContainer(testing: true)
//            let context = ModelContext(testingContainer)
//
//            var viewModel = ToDoSheetView.ViewModel(todo: ToDo(), isNew: true, context: context)
//            viewModel.draftToDo.title = "TestToDo"
//            viewModel.trySave()
//
//            var todos = try context.fetch(FetchDescriptor<ToDo>())
//            #expect(todos.count == 1)
//
//            let testToDo = try #require(todos.filter({ $0.title == "TestToDo" }).first)
//            viewModel = ToDoSheetView.ViewModel(todo: testToDo, isNew: false, context: context)
//            viewModel.draftToDo.title = "EditedTestToDo"
//            viewModel.trySave()
//
//            todos = try context.fetch(FetchDescriptor<ToDo>())
//            #expect(todos.count == 1)
//            #expect(todos.filter({ $0.title == "EditedTestToDo" }).first != nil)
//        }
//    }
//
//    @Suite("Study Routine ViewModels Tests", .tags(.studies)) @MainActor struct StudyRoutineViewModelsTests {
//        @Test func `Study Routine ViewModel – Fetch & Scroll Behavior Tests`() throws {
//            let testingContainer = createContainer(testing: true)
//            let context = ModelContext(testingContainer)
//
//            try SampleDataManager.shared.insertSampleData(in: context)
//
//            let viewModel = SRView.ViewModel(context: context)
//            #expect(viewModel.studies.count == SampleDataManager.shared.expectedStudiesCount)
//
//            viewModel.handleScrollGeoChange(-150)
//            #expect(!viewModel.showTitle)
//            #expect(!viewModel.showSelectedWeekday)
//            #expect(!viewModel.hideOverlay)
//
//            viewModel.handleScrollGeoChange(-100)
//            #expect(viewModel.showTitle)
//            #expect(!viewModel.showSelectedWeekday)
//            #expect(!viewModel.hideOverlay)
//
//            viewModel.handleScrollGeoChange(0)
//            #expect(viewModel.showTitle)
//            #expect(viewModel.showSelectedWeekday)
//            #expect(!viewModel.hideOverlay)
//
//            viewModel.handleScrollGeoChange(-300)
//            #expect(!viewModel.showTitle)
//            #expect(!viewModel.showSelectedWeekday)
//            #expect(viewModel.hideOverlay)
//        }
//
//        @Test func `Subjects Sheet ViewModel – Conflict, Insert & Edit Tests`() throws {
//            let testingContainer = createContainer(testing: true)
//            let context = ModelContext(testingContainer)
//
//            var viewModel = SRSheetView.ViewModel(study: SRStudy(), isNew: true, context: context)
//            viewModel.draftStudy.name = "TestStudy"
//            viewModel.trySave()
//
//            var studies = try context.fetch(FetchDescriptor<SRStudy>())
//            #expect(studies.count == 1)
//
//            let testStudy = try #require(studies.filter({ $0.name == "TestStudy" }).first)
//            viewModel = SRSheetView.ViewModel(study: testStudy, isNew: false, context: context)
//            viewModel.draftStudy.name = "EditedTestStudy"
//            viewModel.trySave()
//
//            studies = try context.fetch(FetchDescriptor<SRStudy>())
//            #expect(studies.count == 1)
//            #expect(studies.filter({ $0.name == "EditedTestStudy" }).first != nil)
//        }
//    }
//}
