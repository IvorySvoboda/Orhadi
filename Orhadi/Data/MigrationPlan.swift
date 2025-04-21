//
//  MigrationPlan.swift
//  Orhadi
//
//  Created by Zyvoxi . on 10/04/25.
//

import Foundation
import SwiftData

enum MigrationPlan: SchemaMigrationPlan {

    static var schemas: [any VersionedSchema.Type] {
        [OrhadiSchemaV1.self, OrhadiSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        []
    }

    static var migrateV1toV2 = MigrationStage.custom(
        fromVersion: OrhadiSchemaV1.self,
        toVersion: OrhadiSchemaV2.self,
        willMigrate: { context in
            let subjects = try context.fetch(FetchDescriptor<OrhadiSchemaV1.Subject>())

            for subject in subjects where subject.isHidden == false {
                context.insert(OrhadiSchemaV2.SRSubject(
                    name: subject.name,
                    studyDay: subject.studyDay,
                    studyTime: subject.studyTime,
                    lastStudied: subject.lastStudied
                ))
            }
        },
        didMigrate: nil)
}
