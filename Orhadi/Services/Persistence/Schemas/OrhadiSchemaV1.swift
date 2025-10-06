//
//  OrhadiSchemaV1.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 23/04/25.
//

import Foundation
import SwiftData

typealias CurrentSchema = OrhadiSchemaV1
typealias Subject = CurrentSchema.Subject
typealias SRStudy = CurrentSchema.SRStudy
typealias ToDo = CurrentSchema.ToDo
typealias Settings = CurrentSchema.Settings
typealias Teacher = CurrentSchema.Teacher

enum OrhadiSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Teacher.self,
         Subject.self,
         ToDo.self,
         SRStudy.self,
         Settings.self]
    }

    // MARK: - Teacher

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

    // MARK: - Subject

    @Model
    class Subject: Codable {
        @Attribute(.unique) var id: String = UUID().uuidString
        var name: String = ""
        var teacher: Teacher?
        var schedule: Date = Date(timeIntervalSince1970: 0)
        var startTime: Date = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date(timeIntervalSince1970: 0))!
        var endTime: Date = Calendar.current.date(bySettingHour: 7, minute: 50, second: 0, of: Date(timeIntervalSince1970: 0))!
        var place: String = ""
        var isRecess: Bool = false
        var isSubjectDeleted: Bool = false
        var deletedAt: Date?

        var isOngoing: Bool {
            let calendar = Calendar.current
            let todayWeekday = calendar.component(.weekday, from: .now)
            let subjectWeekday = calendar.component(.weekday, from: schedule)
            
            let subjectStart = calendar.date(
                bySettingHour: calendar.component(.hour, from: startTime),
                minute: calendar.component(.minute, from: startTime),
                second: 0,
                of: .now
            ) ?? .distantPast

            let subjectEnd = calendar.date(
                bySettingHour: calendar.component(.hour, from: endTime),
                minute: calendar.component(.minute, from: endTime),
                second: 0,
                of: .now
            ) ?? .distantFuture

            return .now >= subjectStart && .now < subjectEnd && todayWeekday == subjectWeekday
        }

        init(
            name: String = "",
            teacher: Teacher? = nil,
            schedule: Date = Date(timeIntervalSince1970: 0),
            startTime: Date = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date(timeIntervalSince1970: 0))!,
            endTime: Date = Calendar.current.date(bySettingHour: 7, minute: 50, second: 0, of: Date(timeIntervalSince1970: 0))!,
            place: String = "",
            isRecess: Bool,
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
                name: "English",
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
            try container.encodeIfPresent(teacher, forKey: .teacher)
            try container.encode(schedule, forKey: .schedule)
            try container.encode(startTime, forKey: .startTime)
            try container.encode(endTime, forKey: .endTime)
            try container.encode(place, forKey: .place)
            try container.encode(isRecess, forKey: .isRecess)
        }
    }

    // MARK: - ToDo

    @Model
    class ToDo: Codable {
        @Attribute(.unique) var id: String = UUID().uuidString
        var title: String = ""
        private var infoData: Data = Data()
        var dueDate: Date = Calendar.current.startOfDay(for: Date())
        var withHour: Bool = false
        var createdAt: Date = Date()
        var isCompleted: Bool = false
        var completedAt: Date?
        var priority: Priority = Priority.none
        var isArchived: Bool = false
        var isToDoDeleted: Bool = false
        var deletedAt: Date?

        var info: AttributedString {
            get { (try? JSONDecoder().decode(AttributedString.self, from: infoData)) ?? AttributedString("") }
            set { infoData = (try? JSONEncoder().encode(newValue)) ?? Data() }
        }

        init(
            title: String = "",
            info: AttributedString = "",
            dueDate: Date = Calendar.current.startOfDay(for: Date()),
            withHour: Bool = false,
            createdAt: Date = Date(),
            isCompleted: Bool = false,
            completedAt: Date? = nil,
            priority: Priority = Priority.none,
            isArchived: Bool = false
        ) {
            self.title = title
            self.info = info
            self.dueDate = dueDate
            self.withHour = withHour
            self.createdAt = createdAt
            self.isCompleted = isCompleted
            self.completedAt = completedAt
            self.priority = priority
            self.isArchived = isArchived
        }

        static let sampleData: [ToDo] = [
            .init(
                title: "Comprar material de arte",
                info: "Tintas, pincéis e papéis para o projeto de pintura",
                dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
                withHour: false,
                createdAt: Date(),
                isCompleted: false,
                priority: .medium,
                isArchived: false
            ),
            .init(
                title: "Enviar relatório mensal",
                info: "Relatório de desempenho para o gestor",
                dueDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                withHour: true,
                createdAt: Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date(),
                isCompleted: true,
                completedAt: Calendar.current.date(byAdding: .day, value: -1, to: Date()),
                priority: .high,
                isArchived: false
            ),
            .init(
                title: "Ligar para fornecedor",
                info: "Negociar valores para a próxima remessa",
                dueDate: Calendar.current.date(byAdding: .hour, value: 5, to: Date()) ?? Date(),
                withHour: true,
                createdAt: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                isCompleted: false,
                priority: .low,
                isArchived: false
            ),
            .init(
                title: "Study SwiftUI avançado",
                info: "Terminar curso sobre animações e performance",
                dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
                withHour: false,
                createdAt: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
                isCompleted: false,
                priority: .medium,
                isArchived: false
            ),
            .init(
                title: "Organizar documentos antigos",
                info: "Separar documentos para arquivar",
                dueDate: Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date(),
                withHour: false,
                createdAt: Calendar.current.date(byAdding: .day, value: -40, to: Date()) ?? Date(),
                isCompleted: true,
                completedAt: Calendar.current.date(byAdding: .day, value: -29, to: Date()),
                priority: .none,
                isArchived: true
            )
        ]

        enum CodingKeys: CodingKey {
            case title
            case info
            case dueDate
            case withHour
            case createdAt
            case isCompleted
            case completedAt
            case priority
            case isArchived
        }

        required init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            title = try container.decode(String.self, forKey: .title)
            info = try container.decode(AttributedString.self, forKey: .info)
            dueDate = try container.decode(Date.self, forKey: .dueDate)
            withHour = try container.decode(Bool.self, forKey: .withHour)
            createdAt = try container.decode(Date.self, forKey: .createdAt)
            isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
            completedAt = try container.decodeIfPresent(Date.self, forKey: .completedAt)
            priority = try container.decode(Priority.self, forKey: .priority)
            isArchived = try container.decode(Bool.self, forKey: .isArchived)
        }

        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(title, forKey: .title)
            try container.encode(info, forKey: .info)
            try container.encode(dueDate, forKey: .dueDate)
            try container.encode(withHour, forKey: .withHour)
            try container.encode(createdAt, forKey: .createdAt)
            try container.encode(isCompleted, forKey: .isCompleted)
            try container.encodeIfPresent(completedAt, forKey: .completedAt)
            try container.encode(priority, forKey: .priority)
            try container.encode(isArchived, forKey: .isArchived)
        }
    }

    // MARK: - SRStudy

    @Model
    class SRStudy: Codable {
        @Attribute(.unique) var id: String = UUID().uuidString
        var name: String = ""
        var studyDay: Date = Date(timeIntervalSince1970: 0)
        var studyTime: Date = Calendar.current.date(bySettingHour: 0, minute: 30, second: 0, of: Date(timeIntervalSince1970: 0))!
        var lastStudied: Date = Date(timeIntervalSince1970: 0)
        var isStudyDeleted: Bool = false
        var deletedAt: Date?

        init(
            name: String = "",
            studyDay: Date = Date(timeIntervalSince1970: 0),
            studyTime: Date = Calendar.current.date(bySettingHour: 0, minute: 30, second: 0, of: Date(timeIntervalSince1970: 0))!,
            lastStudied: Date = Date(timeIntervalSince1970: 0),
        ) {
            self.name = name
            self.studyDay = studyDay
            self.studyTime = studyTime
            self.lastStudied = lastStudied
        }

        static let sampleData = [
            SRStudy(name: "English"),
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

    // MARK: - Settings

    @Model
    class Settings {
        /// App
        var theme: Theme

        /// Study Routine
        var breakTime: TimeInterval

        /// Subjects
        var showCurrentSubjectIndicator: Bool = true

        /// ToDos
        var scheduleNotifications: Bool

        init(
            theme: Theme = .auto,
            breakTime: TimeInterval = 600,
            showCurrentSubjectIndicator: Bool = true,
            scheduleNotifications: Bool = true,
        ) {
            self.theme = theme
            self.breakTime = breakTime
            self.showCurrentSubjectIndicator = showCurrentSubjectIndicator
            self.scheduleNotifications = scheduleNotifications
        }
    }
}
