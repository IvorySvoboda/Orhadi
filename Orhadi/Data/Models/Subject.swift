//
//  Subject.swift
//  Orhadi
//
//  Created by Zyvoxi . on 28/03/25.
//

import Foundation
import SwiftData
import CoreTransferable

enum SubjectSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Subject.self]
    }

    @Model
    class Subject: Codable {
        @Attribute(.unique) var id: String
        var name: String
        var teacher: String
        var email: String
        var schedule: Date
        var startTime: Date
        var endTime: Date
        var place: String
        var isRecess: Bool

        /// Variáveis para o StudyRoutine.
        var studyDay: Date
        var studyTime: Date
        var lastStudied: Date
        var isHidden: Bool

        init(
            id: String = UUID().uuidString,
            name: String,
            teacher: String,
            email: String,
            schedule: Date,
            startTime: Date,
            endTime: Date,
            place: String,
            isRecess: Bool,
            studyDay: Date = Date(),
            studyTime: Date = Calendar.current.date(
                bySettingHour: 0,
                minute: 30,
                second: 0,
                of: Date()
            )!,
            lastStudied: Date = Date() - 604800,
            isHidden: Bool = false
        ) {
            self.id = id
            self.name = name
            self.teacher = teacher
            self.email = email
            self.schedule = schedule
            self.startTime = startTime
            self.endTime = endTime
            self.place = place
            self.isRecess = isRecess
            self.studyDay = studyDay
            self.studyTime = studyTime
            self.lastStudied = lastStudied
            self.isHidden = isHidden
        }

        static let sampleData = [
            Subject(
                name: "Português",
                teacher: "Prof. D",
                email: "example@email.com",
                schedule: Date(),
                startTime: Date(),
                endTime: Date(),
                place: "Sala 109",
                isRecess: false
            ),
            Subject(
                name: "Biologia",
                teacher: "Prof. J",
                email: "example@email.com",
                schedule: Date(),
                startTime: Date(),
                endTime: Date(),
                place: "Sala 109",
                isRecess: false
            ),
            Subject(
                name: "Química",
                teacher: "Prof. H",
                email: "example@email.com",
                schedule: Date(),
                startTime: Date(),
                endTime: Date(),
                place: "Sala 109",
                isRecess: false
            ),
        ]

        enum CodingKeys: CodingKey {
            case id
            case name
            case teacher
            case email
            case schedule
            case startTime
            case endTime
            case place
            case isRecess
            case studyDay
            case studyTime
            case lastStudied
            case isHidden
        }

        required init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            teacher = try container.decode(String.self, forKey: .teacher)
            email = try container.decode(String.self, forKey: .email)
            schedule = try container.decode(Date.self, forKey: .schedule)
            startTime = try container.decode(Date.self, forKey: .startTime)
            endTime = try container.decode(Date.self, forKey: .endTime)
            place = try container.decode(String.self, forKey: .place)
            isRecess = try container.decode(Bool.self, forKey: .isRecess)
            studyDay = try container.decode(Date.self, forKey: .studyDay)
            studyTime = try container.decode(Date.self, forKey: .studyTime)
            lastStudied = try container.decode(Date.self, forKey: .lastStudied)
            isHidden = try container.decode(Bool.self, forKey: .isHidden)
        }

        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(name, forKey: .name)
            try container.encode(teacher, forKey: .teacher)
            try container.encode(email, forKey: .email)
            try container.encode(schedule, forKey: .schedule)
            try container.encode(startTime, forKey: .startTime)
            try container.encode(endTime, forKey: .endTime)
            try container.encode(place, forKey: .place)
            try container.encode(isRecess, forKey: .isRecess)
            try container.encode(studyDay, forKey: .studyDay)
            try container.encode(studyTime, forKey: .studyTime)
            try container.encode(lastStudied, forKey: .lastStudied)
            try container.encode(isHidden, forKey: .isHidden)
        }
    }
}

struct SubjectTransferable: Transferable {
    var subjects: [Subject]

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .data) {
            return try JSONEncoder().encode($0.subjects)
        }
    }
}
