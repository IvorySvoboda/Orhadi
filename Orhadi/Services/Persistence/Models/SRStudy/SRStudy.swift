//
//  SRStudy.swift
//  Orhadi
//
//  Created by Zyvoxi . on 29/04/25.
//

import SwiftData
import Foundation

extension OrhadiSchemaV1 {
    @Model
    class SRStudy: Codable {
        var name: String = ""
        var studyDay: Date = Date(timeIntervalSince1970: 0)
        var studyTime: Date = Calendar.current.date(bySettingHour: 0, minute: 30, second: 0, of: Date(timeIntervalSince1970: 0))!
        var lastStudied: Date = Date(timeIntervalSince1970: 0)
        var isDeleted: Bool = false

        init(
            name: String = "",
            studyDay: Date = Date(timeIntervalSince1970: 0),
            studyTime: Date = Calendar.current.date(bySettingHour: 0, minute: 30, second: 0, of: Date(timeIntervalSince1970: 0))!,
            lastStudied: Date = Date(timeIntervalSince1970: 0),
            isDeleted: Bool = true
        ) {
            self.name = name
            self.studyDay = studyDay
            self.studyTime = studyTime
            self.lastStudied = lastStudied
            self.isDeleted = isDeleted
        }

        static let sampleData = [
            SRStudy(name: "Português"),
            SRStudy(name: "Matemática"),
            SRStudy(name: "História"),
        ]

        enum CodingKeys: CodingKey {
            case name
            case studyDay
            case studyTime
            case lastStudied
        }

        required init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(String.self, forKey: .name)
            studyDay = try container.decode(Date.self, forKey: .studyDay)
            studyTime = try container.decode(Date.self, forKey: .studyTime)
            lastStudied = try container.decode(Date.self, forKey: .lastStudied)
        }

        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(studyDay, forKey: .studyDay)
            try container.encode(studyTime, forKey: .studyTime)
            try container.encode(lastStudied, forKey: .lastStudied)
        }
    }
}
