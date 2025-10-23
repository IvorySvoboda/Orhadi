//
//  DraftToDo.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 22/10/25.
//

import Foundation

struct DraftToDo {
    var title: String
    var info: AttributedString
    var priority: Priority
    var dueDate: Date
    var withHour: Bool

    init(title: String, info: AttributedString, priority: Priority, dueDate: Date, withHour: Bool) {
        self.title = title
        self.info = info
        self.priority = priority
        self.dueDate = dueDate
        self.withHour = withHour
    }

    init(from todo: ToDo) {
        self.title = todo.title
        self.info = todo.info
        self.priority = todo.priority
        self.dueDate = todo.dueDate
        self.withHour = todo.withHour
    }
}
