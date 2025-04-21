//
//  Transferable.swift
//  Orhadi
//
//  Created by Zyvoxi . on 14/04/25.
//

import Foundation
import CoreTransferable

struct SubjectTransferable: Transferable {
    var subjects: [Subject]

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .data) {
            return try JSONEncoder().encode($0.subjects)
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

struct TeacherTransferable: Transferable {
    var teachers: [Teacher]

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .data) {
            return try JSONEncoder().encode($0.teachers)
        }
    }
}
