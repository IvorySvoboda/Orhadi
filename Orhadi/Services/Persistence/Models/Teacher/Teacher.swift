//
//  Teacher.swift
//  Orhadi
//
//  Created by Zyvoxi . on 29/04/25.
//

import Foundation
import SwiftData

extension OrhadiSchemaV1 {
    @Model
    class Teacher: Codable {
        @Attribute(.unique) var name: String = ""
        var email: String = ""
        @Relationship(inverse: \Subject.teacher) var subjects: [Subject] = []

        init(
            name: String = "",
            email: String = ""
        ) {
            self.name = name
            self.email = email
        }

        enum CodingKeys: CodingKey {
            case name
            case email
        }

        required init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(String.self, forKey: .name)
            email = try container.decode(String.self, forKey: .email)
        }

        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(email, forKey: .email)
        }
    }
}
