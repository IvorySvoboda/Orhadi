//
//  OrhadiSchemaV1.swift
//  Orhadi
//
//  Created by Zyvoxi . on 16/04/25.
//

import Foundation
import SwiftData

enum OrhadiSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            Subject.self,
            ToDo.self,
            Settings.self,
            Teacher.self,
            UserProfile.self,
            Achievement.self
        ]
    }

    @Model
    class Subject: Codable {
        var name: String
        @Relationship(deleteRule: .nullify) var teacher: Teacher?
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
            name: String = "",
            teacher: Teacher? = nil,
            schedule: Date = defaultSchedule(),
            startTime: Date = defaultStartTime(),
            endTime: Date = defaultStartTime() + TimeInterval(50 * 60),
            place: String = "",
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
            self.name = name
            self.teacher = teacher
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
                teacher: Teacher(name: "Teste", email: "email@exemple.com"),
                schedule: Date(),
                startTime: Date(),
                endTime: Date(),
                place: "Sala 109",
                isRecess: false
            ),
            Subject(
                name: "Biologia",
                teacher: Teacher(name: "Teste2", email: "email@exemple.com"),
                schedule: Date(),
                startTime: Date(),
                endTime: Date(),
                place: "Sala 109",
                isRecess: false
            ),
            Subject(
                name: "Química",
                teacher: Teacher(name: "Teste3", email: "email@exemple.com"),
                schedule: Date(),
                startTime: Date(),
                endTime: Date(),
                place: "Sala 109",
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
            case studyDay
            case studyTime
            case lastStudied
            case isHidden
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
            studyDay = try container.decode(Date.self, forKey: .studyDay)
            studyTime = try container.decode(Date.self, forKey: .studyTime)
            lastStudied = try container.decode(Date.self, forKey: .lastStudied)
            isHidden = try container.decode(Bool.self, forKey: .isHidden)
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
            try container.encode(studyDay, forKey: .studyDay)
            try container.encode(studyTime, forKey: .studyTime)
            try container.encode(lastStudied, forKey: .lastStudied)
            try container.encode(isHidden, forKey: .isHidden)
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
            title: String,
            info: String,
            dueDate: Date,
            isCompleted: Bool = false
        ) {
            self.id = id
            self.title = title
            self.info = info
            self.dueDate = dueDate
            self.isCompleted = isCompleted
        }

        static let sampleData = [
            ToDo(title: "Tarefa", info: "", dueDate: Date(), isCompleted: false),
            ToDo(title: "Tarefa", info: "", dueDate: Date() + 3600, isCompleted: false),
            ToDo(title: "Tarefa", info: "", dueDate: Date(), isCompleted: true)
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
    class Settings {
        /// App
        var theme: Theme

        /// Study Routine
        var breakTime: TimeInterval
        var studyGoal: TimeInterval

        /// Subjects
        var subjectsDeleteConfirmation: Bool

        /// ToDos
        var scheduleNotifications: Bool
        var todosDeleteConfirmation: Bool

        init(
            theme: Theme = .auto,
            breakTime: TimeInterval = 600,
            studyGoal: TimeInterval = 3600,
            subjectsDeleteConfirmation: Bool = true,
            scheduleNotifications: Bool = true,
            todosDeleteConfirmation: Bool = true,
        ) {
            self.theme = theme
            self.breakTime = breakTime
            self.studyGoal = studyGoal
            self.subjectsDeleteConfirmation = subjectsDeleteConfirmation
            self.scheduleNotifications = scheduleNotifications
            self.todosDeleteConfirmation = todosDeleteConfirmation
        }
    }

    @Model
    class Teacher: Codable {
        @Attribute(.unique) var name: String
        var email: String

        init(
            name: String,
            email: String
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
}

