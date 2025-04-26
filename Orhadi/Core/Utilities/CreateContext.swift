//
//  CreateContext.swift
//  Orhadi
//
//  Created by Zyvoxi . on 23/04/25.
//

import SwiftData
import Foundation

func createContext() throws -> ModelContext {
    let path = URL.documentsDirectory.appending(path: "database.store")
    let config = ModelConfiguration(url: path)
    let container = try ModelContainer(
        for: Schema(versionedSchema: CurrentSchema.self),
        migrationPlan: MigrationPlan.self,
        configurations: config
    )
    return ModelContext(container)
}
