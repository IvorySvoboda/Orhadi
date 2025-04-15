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
        [migrateOrhadiV1toV2]
    }

    private static var V1Subjects = [V1SubjectData]()

    static let migrateOrhadiV1toV2 = MigrationStage.custom(
        fromVersion: OrhadiSchemaV1.self,
        toVersion: OrhadiSchemaV2.self,

        willMigrate: { context in
            let oldSubjects = try context.fetch(FetchDescriptor<OrhadiSchemaV1.Subject>())

            V1Subjects = oldSubjects.map {
                V1SubjectData(
                    name: $0.name,
                    teacherName: $0.teacher,
                    teacherEmail: $0.email,
                    schedule: $0.schedule,
                    startTime: $0.startTime,
                    endTime: $0.endTime,
                    place: $0.place,
                    isRecess: $0.isRecess
                )
            }

            try context.delete(model: OrhadiSchemaV1.Subject.self)
            try context.save()
        },

        didMigrate: { context in
            for subject in V1Subjects {
                var teacher: OrhadiSchemaV2.Teacher? = nil

                if !subject.teacherName.isEmpty || !subject.teacherEmail.isEmpty {
                    let teacherName = subject.teacherName

                    let existingTeacher = try? context.fetch(
                        FetchDescriptor<OrhadiSchemaV2.Teacher>(
                            predicate: #Predicate { $0.name == teacherName }
                        )
                    ).first

                    if let foundTeacher = existingTeacher {
                        teacher = foundTeacher
                    } else {
                        teacher = OrhadiSchemaV2.Teacher(
                            name: subject.teacherName,
                            email: subject.teacherEmail
                        )
                        context.insert(teacher!)
                    }
                }

                context.insert(
                    OrhadiSchemaV2.Subject(
                        name: subject.name,
                        teacher: teacher,
                        schedule: subject.schedule,
                        startTime: subject.startTime,
                        endTime: subject.endTime,
                        place: subject.place,
                        isRecess: subject.isRecess
                    )
                )
            }

            try context.save()
        }
    )
}

struct V1SubjectData {
    var name: String
    var teacherName: String
    var teacherEmail: String
    var schedule: Date
    var startTime: Date
    var endTime: Date
    var place: String
    var isRecess: Bool
}
