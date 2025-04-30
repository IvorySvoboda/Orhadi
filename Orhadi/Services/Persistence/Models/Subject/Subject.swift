//
//  Subject.swift
//  Orhadi
//
//  Created by Zyvoxi . on 30/04/25.
//

import Foundation
import SwiftData

extension OrhadiSchemaV1 {
    @Model
    class Subject: Codable {
        var name: String = ""
        var teacher: Teacher? = nil
        var schedule: Date = Date(timeIntervalSince1970: 0)
        var startTime: Date = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date(timeIntervalSince1970: 0))!
        var endTime: Date = Calendar.current.date(bySettingHour: 7, minute: 50, second: 0, of: Date(timeIntervalSince1970: 0))!
        var place: String = ""
        var isRecess: Bool = false
        var isDeleted: Bool = false

        init(
            name: String = "",
            teacher: Teacher? = nil,
            schedule: Date = Date(timeIntervalSince1970: 0),
            startTime: Date = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date(timeIntervalSince1970: 0))!,
            endTime: Date = Calendar.current.date(bySettingHour: 7, minute: 50, second: 0, of: Date(timeIntervalSince1970: 0))!,
            place: String = "",
            isRecess: Bool,
            isDeleted: Bool = false
        ) {
            self.name = name
            self.teacher = teacher
            self.schedule = schedule
            self.startTime = startTime
            self.endTime = endTime
            self.place = place
            self.isRecess = isRecess
            self.isDeleted = isDeleted
        }

        static let sampleData = [
            Subject(
                name: "Português",
                teacher: Teacher(name: "Ana Lima", email: "ana.lima@example.com"),
                schedule: Date(),
                startTime: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!,
                endTime: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!,
                place: "Sala 109",
                isRecess: false
            ),
            Subject(
                name: "Matemática",
                teacher: Teacher(name: "Carlos Mendes", email: "carlos.mendes@example.com"),
                schedule: Date(),
                startTime: Calendar.current.date(bySettingHour: 9, minute: 15, second: 0, of: Date())!,
                endTime: Calendar.current.date(bySettingHour: 10, minute: 15, second: 0, of: Date())!,
                place: "Sala 202",
                isRecess: false
            ),
            Subject(
                name: "",
                teacher: nil,
                schedule: Date(),
                startTime: Calendar.current.date(bySettingHour: 10, minute: 15, second: 0, of: Date())!,
                endTime: Calendar.current.date(bySettingHour: 10, minute: 30, second: 0, of: Date())!,
                place: "",
                isRecess: true
            ),
            Subject(
                name: "História",
                teacher: Teacher(name: "Beatriz Rocha", email: "beatriz.rocha@example.com"),
                schedule: Date(),
                startTime: Calendar.current.date(bySettingHour: 10, minute: 30, second: 0, of: Date())!,
                endTime: Calendar.current.date(bySettingHour: 11, minute: 30, second: 0, of: Date())!,
                place: "Sala 105",
                isRecess: false
            ),
        ]

        enum CodingKeys: CodingKey {
            case name
            case teacher
            case schedule
            case startTime
            case endTime
            case place
            case isRecess
        }

        required init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(String.self, forKey: .name)
            teacher = try container.decodeIfPresent(Teacher.self, forKey: .teacher)
            schedule = try container.decode(Date.self, forKey: .schedule)
            startTime = try container.decode(Date.self, forKey: .startTime)
            endTime = try container.decode(Date.self, forKey: .endTime)
            place = try container.decode(String.self, forKey: .place)
            isRecess = try container.decode(Bool.self, forKey: .isRecess)
        }

        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encodeIfPresent(teacher, forKey: .teacher)
            try container.encode(schedule, forKey: .schedule)
            try container.encode(startTime, forKey: .startTime)
            try container.encode(endTime, forKey: .endTime)
            try container.encode(place, forKey: .place)
            try container.encode(isRecess, forKey: .isRecess)
        }
    }
}
