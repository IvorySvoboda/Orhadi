//
//  OrhadiSchemaV2.swift
//  Orhadi
//
//  Created by Zyvoxi . on 23/04/25.
//

import Foundation
import SwiftData

enum OrhadiSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            Subject.self,
            SRStudy.self,
            ToDo.self,
            Settings.self,
            Teacher.self,
            UserProfile.self,
            Achievement.self,
        ]
    }

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

    @Model
    class Subject: Codable {
        var name: String = ""
        var teacher: Teacher? = nil
        var schedule: Date = Date(timeIntervalSince1970: 0)
        var startTime: Date = Calendar.current.date(
            bySettingHour: 7,
            minute: 0,
            second: 0,
            of: Date(timeIntervalSince1970: 0)
        )!
        var endTime: Date = Calendar.current.date(
            bySettingHour: 7,
            minute: 50,
            second: 0,
            of: Date(timeIntervalSince1970: 0)
        )!
        var place: String = ""
        var isRecess: Bool = false

        init(
            name: String = "",
            teacher: Teacher? = nil,
            schedule: Date = Date(timeIntervalSince1970: 0),
            startTime: Date = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date(timeIntervalSince1970: 0))!,
            endTime: Date = Calendar.current.date(bySettingHour: 7, minute: 50, second: 0, of: Date(timeIntervalSince1970: 0))!,
            place: String = "",
            isRecess: Bool
        ) {
            self.name = name
            self.teacher = teacher
            self.schedule = schedule
            self.startTime = startTime
            self.endTime = endTime
            self.place = place
            self.isRecess = isRecess
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
            )
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
            try container.encode(teacher, forKey: .teacher)
            try container.encode(schedule, forKey: .schedule)
            try container.encode(startTime, forKey: .startTime)
            try container.encode(endTime, forKey: .endTime)
            try container.encode(place, forKey: .place)
            try container.encode(isRecess, forKey: .isRecess)
        }
    }

    @Model
    class SRStudy: Codable {
        var name: String = ""
        var studyDay: Date = Date(timeIntervalSince1970: 0)
        var studyTime: Date = Calendar.current.date(
            bySettingHour: 0,
            minute: 30,
            second: 0,
            of: Date(timeIntervalSince1970: 0)
        )!
        var lastStudied: Date = Date(timeIntervalSince1970: 0)

        init(
            name: String = "",
            studyDay: Date = Date(timeIntervalSince1970: 0),
            studyTime: Date = Calendar.current.date(
                bySettingHour: 0,
                minute: 30,
                second: 0,
                of: Date(timeIntervalSince1970: 0)
            )!,
            lastStudied: Date = Date(timeIntervalSince1970: 0)
        ) {
            self.name = name
            self.studyDay = studyDay
            self.studyTime = studyTime
            self.lastStudied = lastStudied
        }

        static let sampleData = [
            SRStudy(name: "Português"),
            SRStudy(name: "Matemática"),
            SRStudy(name: "História")
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

    @Model
    class ToDo: Codable {
        @Attribute(.unique) var id: String
        var title: String
        var info: String
        var dueDate: Date
        var isCompleted: Bool

        init(
            id: String = UUID().uuidString,
            title: String = "",
            info: String = "",
            dueDate: Date = .now.addingTimeInterval(3600),
            isCompleted: Bool = false
        ) {
            self.id = id
            self.title = title
            self.info = info
            self.dueDate = dueDate
            self.isCompleted = isCompleted
        }

        static let sampleData = [
            ToDo(
                title: "Tarefa",
                info: "",
                dueDate: Date(),
                isCompleted: false
            ),
            ToDo(
                title: "Tarefa",
                info: "",
                dueDate: Date().addingTimeInterval(3600),
                isCompleted: false
            ),
            ToDo(title: "Tarefa",
                 info: "",
                 dueDate: Date(),
                 isCompleted: true),
        ]

        enum CodingKeys: CodingKey {
            case id
            case title
            case info
            case dueDate
            case isCompleted
        }

        required init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            title = try container.decode(String.self, forKey: .title)
            info = try container.decode(String.self, forKey: .info)
            dueDate = try container.decode(Date.self, forKey: .dueDate)
            isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        }

        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(title, forKey: .title)
            try container.encode(info, forKey: .info)
            try container.encode(dueDate, forKey: .dueDate)
            try container.encode(isCompleted, forKey: .isCompleted)
        }
    }

    @Model
    class UserProfile {
        @Attribute(.unique) var name: String
        var photo: Data?
        var level: Int
        var xp: Int
        var timeStudied: Int
        var completedToDos: Int

        init(
            name: String = "Orhadi",
            photo: Data? = nil,
            level: Int = 1,
            xp: Int = 0,
            timeStudied: Int = 0,
            completedToDos: Int = 0
        ) {
            self.name = name
            self.photo = photo
            self.level = level
            self.xp = xp
            self.timeStudied = timeStudied
            self.completedToDos = completedToDos
        }
    }

    @Model
    class Achievement {
        @Attribute(.unique) var id: String
        var name: String
        var imageName: String
        var descriptionText: String
        var isUnlocked: Bool
        var unlockedAt: Date?
        var difficultLevel: Int

        init(
            id: String,
            name: String,
            imageName: String,
            descriptionText: String,
            isUnlocked: Bool = false,
            unlockedAt: Date? = nil,
            difficultLevel: Int
        ) {
            self.id = id
            self.name = name
            self.imageName = imageName
            self.descriptionText = descriptionText
            self.isUnlocked = isUnlocked
            self.unlockedAt = unlockedAt
            self.difficultLevel = difficultLevel
        }
    }

    @Model
    class Settings {
        /// App
        var theme: Theme

        /// Study Routine
        var breakTime: TimeInterval
        var studyGoal: TimeInterval
        var studyDeleteConfirmation: Bool

        /// Subjects
        var subjectsDeleteConfirmation: Bool

        /// ToDos
        var gracePeriod: TimeInterval
        var scheduleNotifications: Bool
        var todosDeleteConfirmation: Bool

        init(
            theme: Theme = .auto,
            breakTime: TimeInterval = 600,
            studyGoal: TimeInterval = 3600,
            studyDeleteConfirmation: Bool = true,
            subjectsDeleteConfirmation: Bool = true,
            gracePeriod: TimeInterval = 86400,
            scheduleNotifications: Bool = true,
            todosDeleteConfirmation: Bool = true,
        ) {
            self.theme = theme
            self.breakTime = breakTime
            self.studyGoal = studyGoal
            self.studyDeleteConfirmation = studyDeleteConfirmation
            self.subjectsDeleteConfirmation = subjectsDeleteConfirmation
            self.gracePeriod = gracePeriod
            self.scheduleNotifications = scheduleNotifications
            self.todosDeleteConfirmation = todosDeleteConfirmation
        }
    }
}
