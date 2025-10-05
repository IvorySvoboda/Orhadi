//
//  CreateContainer.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 23/04/25.
//

import SwiftData
import Foundation

func createContainer() throws -> ModelContainer {
    let container = try ModelContainer(
        for: Schema(versionedSchema: CurrentSchema.self),
        migrationPlan: MigrationPlan.self
    )

    return container
}
