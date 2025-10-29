//
//  CreateContainer.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 23/04/25.
//

import SwiftData
import Foundation

func createContainer() -> ModelContainer {
    do {
        #if DEBUG
        let container = try ModelContainer(
            for: Schema(versionedSchema: CurrentSchema.self),
            migrationPlan: MigrationPlan.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        #else
        let container = try ModelContainer(
            for: Schema(versionedSchema: CurrentSchema.self),
            migrationPlan: MigrationPlan.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: false)
        )
        #endif

        return container
    } catch {
        fatalError(error.localizedDescription)
    }
}
