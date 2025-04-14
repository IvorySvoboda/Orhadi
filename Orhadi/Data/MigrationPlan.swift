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

    private static var teachersV1toV2 = [MigratingTeacherFromV1toV2]()

    static let orhadiV1toV2 = MigrationStage.custom(
        fromVersion: OrhadiSchemaV1.self,
        toVersion: OrhadiSchemaV2.self) { context in
            let subjectsV1 = try context.fetch(FetchDescriptor<OrhadiSchemaV1.Subject>())

            for subject in subjectsV1 {
                context.insert(OrhadiSchemaV2.Subject(
                    name: subject.name,
                    teacher: nil,
                    schedule: subject.schedule,
                    startTime: subject.startTime,
                    endTime: subject.endTime,
                    place: subject.place,
                    isRecess: subject.isRecess
                ))
                if !subject.teacher.isEmpty || !subject.email.isEmpty {
                    teachersV1toV2.append(MigratingTeacherFromV1toV2(teacher: subject.teacher.isEmpty ? "" : subject.teacher, email: subject.email.isEmpty ? "" : subject.email))
                }
            }

            try context.delete(model: OrhadiSchemaV1.Subject.self)

            try context.save()
        } didMigrate: { context in
            for teacher in teachersV1toV2 {
                print(teacher)
            }
        }

}

struct MigratingTeacherFromV1toV2 {
    var teacher: String
    var email: String
}
