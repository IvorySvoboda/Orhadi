//
//  CreateContainer.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 23/04/25.
//

import SwiftData
import Foundation

func createContainer(testing: Bool = false) -> ModelContainer {
    do {
        if testing {
            let path = URL.documentsDirectory.appending(path: "testing_database.store")
            let config = ModelConfiguration(url: path)

            return try ModelContainer(
                for: Schema(versionedSchema: CurrentSchema.self),
                migrationPlan: MigrationPlan.self,
                configurations: config
            )
        } else {
            let container = try ModelContainer(
                for: Schema(versionedSchema: CurrentSchema.self),
                migrationPlan: MigrationPlan.self
            )

            Task { await MainActor.run { container.mainContext.autosaveEnabled = false } }

            return container
        }
    } catch {
        fatalError(error.localizedDescription)
    }
}
