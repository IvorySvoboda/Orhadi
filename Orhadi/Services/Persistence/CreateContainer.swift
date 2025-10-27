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
        let config = ModelConfiguration(isStoredInMemoryOnly: testing)
        let container = try ModelContainer(
            for: Schema(versionedSchema: CurrentSchema.self),
            migrationPlan: MigrationPlan.self,
            configurations: config
        )

        Task { await MainActor.run { container.mainContext.autosaveEnabled = false } }

        return container
    } catch {
        fatalError(error.localizedDescription)
    }
}
