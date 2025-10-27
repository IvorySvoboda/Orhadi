//
//  PreviewHelper.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 04/04/25.
//

import Foundation
import SwiftData

@MainActor
class PreviewHelper {
    static let shared = PreviewHelper()

    let container: ModelContainer

    private init() {
        let modelConfiguration = ModelConfiguration(
            schema: Schema(versionedSchema: CurrentSchema.self), isStoredInMemoryOnly: true
        )

        do {
            container = try ModelContainer(
                for: Schema(versionedSchema: CurrentSchema.self), configurations: [modelConfiguration]
            )

            try SampleDataManager.shared.insertSampleData(in: container.mainContext)
        } catch {
            fatalError(
                "Could not create ModelContainer: \(error.localizedDescription)"
            )
        }
    }
}
