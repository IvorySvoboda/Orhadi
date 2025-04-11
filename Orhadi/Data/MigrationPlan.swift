//
//  MigrationPlan.swift
//  Orhadi
//
//  Created by Zyvoxi . on 10/04/25.
//

import SwiftData

enum MigrationPlan: SchemaMigrationPlan {

    static var schemas: [any VersionedSchema.Type] {
        [SubjectSchemaV1.self,
         SRSubjectSchemaV1.self,
         ToDoSchemaV1.self,
         SettingsSchemaV1.self,
         WeeklyReportSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }

}
