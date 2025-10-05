//
//  Transferable.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 14/04/25.
//

import Foundation
import CoreTransferable

struct SubjectTransferable: Codable, Transferable {
    var subjects: [Subject]

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .data) {
            return try JSONEncoder().encode($0.subjects)
        }
    }
}

struct SRStudyTransferable: Transferable {
    var studies: [SRStudy]

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .data) {
            return try JSONEncoder().encode($0.studies)
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
