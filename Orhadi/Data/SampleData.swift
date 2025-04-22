//
//  SampleData.swift
//  Orhadi
//
//  Created by Zyvoxi . on 04/04/25.
//

import Foundation
import SwiftData

@MainActor
class SampleData {
    static let shared = SampleData()

    let container: ModelContainer

    var context: ModelContext {
        container.mainContext
    }

    private init() {

        let modelConfiguration = ModelConfiguration(
            schema: Schema(versionedSchema: CurrentSchema.self), isStoredInMemoryOnly: true
        )

        do {
            container = try ModelContainer(
                for: Schema(versionedSchema: CurrentSchema.self), configurations: [modelConfiguration]
            )

            insertSampleData()

            try context.save()
        } catch {
            fatalError(
                "Could not create ModelContainer: \(error.localizedDescription)"
            )
        }
    }

    private func insertSampleData() {
        for subject in Subject.sampleData {
            context.insert(subject)
        }
        for todo in ToDo.sampleData {
            context.insert(todo)
        }
        context.insert(Settings())
        context.insert(UserProfile())

        _ = GameManager(context: context)
    }
}
