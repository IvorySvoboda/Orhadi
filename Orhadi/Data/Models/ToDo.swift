//
//  ToDo.swift
//  Orhadi
//
//  Created by Zyvoxi . on 28/03/25.
//

import Foundation
import SwiftData
import CoreTransferable

enum ToDoSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [ToDo.self]
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
}

struct ToDoTransferable: Transferable {
    var todos: [ToDo]

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .data) {
            return try JSONEncoder().encode($0.todos)
        }
    }
}
