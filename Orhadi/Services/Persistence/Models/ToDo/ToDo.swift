//
//  ToDo.swift
//  Orhadi
//
//  Created by Zyvoxi . on 30/04/25.
//

import SwiftData
import Foundation

extension OrhadiSchemaV1 {
    @Model
    class ToDo: Identifiable, Codable {
        @Attribute(.unique) var id: String = UUID().uuidString
        var title: String = ""
        var info: String = ""
        var dueDate: Date = Calendar.current.startOfDay(for: Date())
        var withHour: Bool = false
        var createdAt: Date = Date()
        var isCompleted: Bool = false
        var completedAt: Date?
        var priority: Priority = Priority.none
        var isArchived: Bool = false
        var isDeleted: Bool = false

        init(
            id: String = UUID().uuidString,
            title: String = "",
            info: String = "",
            dueDate: Date = Calendar.current.startOfDay(for: Date()),
            withHour: Bool = false,
            createdAt: Date = Date(),
            isCompleted: Bool = false,
            completedAt: Date? = nil,
            priority: Priority = Priority.none,
            isArchived: Bool = false,
            isDeleted: Bool = false
        ) {
            self.id = id
            self.title = title
            self.info = info
            self.dueDate = dueDate
            self.withHour = withHour
            self.createdAt = createdAt
            self.isCompleted = isCompleted
            self.completedAt = completedAt
            self.priority = priority
            self.isArchived = isArchived
            self.isDeleted = isDeleted
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
                title: "Estudar SwiftUI avançado",
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
            ),
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
            info = try container.decode(String.self, forKey: .info)
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
}
