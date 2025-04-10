//
//  SRSubjects.swift
//  Orhadi
//
//  Created by Zyvoxi . on 30/03/25.
//

import CoreTransferable
import Foundation
import SwiftData

enum SRSubjectSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [SRSubject.self]
    }

    @Model
    class SRSubject: Codable {
        var id: String
        var name: String
        var studyDay: Date
        var studyTime: Date
        var lastStudied: Date

        init(
            id: String = UUID().uuidString,
            name: String,
            studyDay: Date,
            studyTime: Date,
            lastStudied: Date = Calendar.current.date(
                byAdding: .year, value: 2020, to: Date())!
        ) {
            self.id = id
            self.name = name
            self.studyDay = studyDay
            self.studyTime = studyTime
            self.lastStudied = lastStudied
        }

        static let sampleData = [
            SRSubject(
                name: "Português",
                studyDay: Calendar.current.date(
                    byAdding: .weekday, value: 2, to: Date())!,
                studyTime: Calendar.current.date(
                    bySettingHour: 0, minute: 30, second: 0, of: Date())!
            ),
            SRSubject(
                name: "Matemática",
                studyDay: Calendar.current.date(
                    byAdding: .weekday, value: 2, to: Date())!,
                studyTime: Calendar.current.date(
                    bySettingHour: 0, minute: 30, second: 0, of: Date())!
            ),
            SRSubject(
                name: "História",
                studyDay: Calendar.current.date(
                    byAdding: .weekday, value: 2, to: Date())!,
                studyTime: Calendar.current.date(
                    bySettingHour: 0, minute: 30, second: 0, of: Date())!
            ),
            SRSubject(
                name: "Química",
                studyDay: Calendar.current.date(
                    byAdding: .weekday, value: 3, to: Date())!,
                studyTime: Calendar.current.date(
                    bySettingHour: 0, minute: 30, second: 0, of: Date())!
            ),
            SRSubject(
                name: "Geografia",
                studyDay: Calendar.current.date(
                    byAdding: .weekday, value: 3, to: Date())!,
                studyTime: Calendar.current.date(
                    bySettingHour: 0, minute: 30, second: 0, of: Date())!
            ),
            SRSubject(
                name: "Biologia",
                studyDay: Calendar.current.date(
                    byAdding: .weekday, value: 3, to: Date())!,
                studyTime: Calendar.current.date(
                    bySettingHour: 0, minute: 30, second: 0, of: Date())!
            ),
        ]

        enum CodingKeys: CodingKey {
            case id
            case name
            case studyDay
            case studyTime
            case lastStudied
        }

        required init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            studyDay = try container.decode(Date.self, forKey: .studyDay)
            studyTime = try container.decode(Date.self, forKey: .studyTime)
            lastStudied = try container.decode(Date.self, forKey: .lastStudied)
        }

        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(name, forKey: .name)
            try container.encode(studyDay, forKey: .studyDay)
            try container.encode(studyTime, forKey: .studyTime)
            try container.encode(lastStudied, forKey: .lastStudied)
        }
    }
}

struct SRSubjectTransferable: Transferable {
    var subjects: [SRSubject]

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .data) {
            return try JSONEncoder().encode($0.subjects)
        }
    }
}
