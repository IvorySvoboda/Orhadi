//
//  OrhadiSchemaV1.swift
//  Orhadi
//
//  Created by Zyvoxi . on 23/04/25.
//

import Foundation
import SwiftData

enum OrhadiSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Subject.self, SRStudy.self, ToDo.self, Settings.self, Teacher.self, UserProfile.self, Achievement.self]
    }
}
