//
//  TestHealpers.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 23/10/25.
//

import SwiftData
import Testing

@testable import Orhadi

struct TestHealpers {
    static func insertSampleData(using context: ModelContext) throws {
        Subject.sampleData.forEach { context.insert($0) }
        ToDo.sampleData.forEach { context.insert($0) }
        SRStudy.sampleData.forEach { context.insert($0) }

        context.insert(Settings())

        try context.save()
    }

    private static func fetchAll<T: PersistentModel>(_ type: T.Type, using context: ModelContext) throws -> [T] {
        try context.fetch(FetchDescriptor<T>())
    }

    static func getCurrentDataModels(using context: ModelContext) throws -> DataModels {
        DataModels(
            subjects: try fetchAll(Subject.self, using: context),
            teachers: try fetchAll(Teacher.self, using: context),
            todos: try fetchAll(ToDo.self, using: context),
            studies: try fetchAll(SRStudy.self, using: context),
            settings: try fetchAll(Settings.self, using: context)
        )
    }
}
