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
         SettingsSchemaV1.self, SettingsSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [SettingsV1toV2]
    }

    static let SettingsV1toV2 = MigrationStage.custom(
        fromVersion: SettingsSchemaV1.self,
        toVersion: SettingsSchemaV2.self,
        willMigrate: { context in
            let settingsV1 = try context.fetch(FetchDescriptor<SettingsSchemaV1.Settings>()).first
            let settingsV2 = try context.fetch(FetchDescriptor<SettingsSchemaV2.Settings>()).first

            if let v1 = settingsV1, settingsV2 == nil {
                context.insert(SettingsSchemaV2.Settings(
                    theme: v1.theme,
                    breakTime: v1.breakTime,
                    srsubjectsDeleteConfirmation: v1.srsubjectsDeleteConfirmation,
                    studyGoal: 3600,
                    sharedSubjects: v1.sharedSubjects,
                    subjectsDeleteConfirmation: v1.subjectsDeleteConfirmation,
                    scheduleNotifications: v1.scheduleNotifications,
                    todosDeleteConfirmation: v1.todosDeleteConfirmation
                ))
                try context.delete(model: SettingsSchemaV1.Settings.self)
                try context.save()
            }
        },
        didMigrate: nil)

}
