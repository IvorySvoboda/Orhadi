//
//  DraftTeacher.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 23/10/25.
//

import Foundation

struct DraftTeacher {
    var name: String
    var email: String

    init(name: String, email: String) {
        self.name = name
        self.email = email
    }

    init(from teacher: Teacher) {
        self.name = teacher.name
        self.email = teacher.email
    }
}
