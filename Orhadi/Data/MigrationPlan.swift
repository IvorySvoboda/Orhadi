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
        [orhadiV1toV2]
    }

    static let orhadiV1toV2 = MigrationStage.custom(
        fromVersion: OrhadiSchemaV1.self,
        toVersion: OrhadiSchemaV2.self) { context in
            print("migrating...")

            let subjectsV1 = try context.fetch(FetchDescriptor<OrhadiSchemaV1.Subject>())

            for subject in subjectsV1 {
                let hasTeacher = !subject.teacher.isEmpty || !subject.email.isEmpty

                let teacher: OrhadiSchemaV2.Teacher? = hasTeacher ? OrhadiSchemaV2.Teacher(
                    id: UUID().uuidString,
                    name: subject.teacher.isEmpty ? "" : subject.teacher,
                    email: subject.email.isEmpty ? "" : subject.email
                ) : nil

                print("migrating...")

                context.insert(OrhadiSchemaV2.Subject(
                    id: UUID().uuidString,
                    name: subject.name,
                    teacher: teacher,
                    schedule: subject.schedule,
                    startTime: subject.startTime,
                    endTime: subject.endTime,
                    place: subject.place,
                    isRecess: subject.isRecess
                ))
            }

            try context.delete(model: OrhadiSchemaV1.Subject.self)
            print("modelo antigo deletado")
            try context.save()
        } didMigrate: { _ in
            print("Migrated from Orhadi Schema Version 1 to Version 2")
        }

}
