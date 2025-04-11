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
        let schema = Schema([
            Subject.self,
            SRSubject.self,
            ToDo.self,
            Settings.self,
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema, isStoredInMemoryOnly: true
        )

        do {
            container = try ModelContainer(
                for: schema, configurations: [modelConfiguration]
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
        for subject in SRSubject.sampleData {
            context.insert(subject)
        }
        for report in WeeklyReport.sampleData {
            context.insert(report)
        }
        context.insert(Settings())
    }
}
