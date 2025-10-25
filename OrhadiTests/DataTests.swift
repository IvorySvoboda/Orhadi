//
//  OrhadiTests.swift
//  OrhadiTests
//
//  Created by Ivory Svoboda on 23/04/25.
//

import Foundation
import SwiftData
import Testing

@testable import Orhadi

struct DataTests {
    let testingContainer: ModelContainer
    let context: ModelContext

    init(testingContainer: ModelContainer = try! createContainer(testing: true)) {
        self.testingContainer = testingContainer
        self.context = ModelContext(testingContainer)
    }

    @Test func dataSettingsTest() async throws {
        try TestHealpers.insertSampleData(using: context)

        var dataModels = try TestHealpers.getCurrentDataModels(using: context)

        #expect(!dataModels.subjects.isEmpty)
        #expect(!dataModels.teachers.isEmpty)
        #expect(!dataModels.todos.isEmpty)
        #expect(!dataModels.studies.isEmpty)
        #expect(dataModels.settings.count == 1)

        let viewModel = DataSettingsView.ViewModel(container: testingContainer)

        let finished = AsyncStream<Void> { continuation in
            viewModel.onCompletion = { continuation.yield(()) }
        }

        viewModel.eraseAllData()

        /// espera a task `eraseAllData()` terminar de forma determinística
        for await _ in finished { break }

        dataModels = try TestHealpers.getCurrentDataModels(using: context)

        #expect(dataModels.subjects.isEmpty)
        #expect(dataModels.teachers.isEmpty)
        #expect(dataModels.todos.isEmpty)
        #expect(dataModels.studies.isEmpty)
        #expect(dataModels.settings.count == 1)

        try testingContainer.erase()
    }
}
