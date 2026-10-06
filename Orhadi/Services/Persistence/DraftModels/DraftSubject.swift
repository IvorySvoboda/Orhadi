//
//  DraftSubject.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 22/10/25.
//

import Foundation
import SwiftData

struct DraftSubject {
    var name: String
    var teacher: Teacher?
    var schedule: Date
    var startTime: Date
    var endTime: Date
    var place: String
    var isRecess: Bool
    var originalID: PersistentIdentifier?

    init(
        name: String,
        teacher: Teacher? = nil,
        schedule: Date,
        startTime: Date,
        endTime: Date,
        place: String,
        isRecess: Bool
    ) {
        self.name = name
        self.teacher = teacher
        self.schedule = schedule
        self.startTime = startTime
        self.endTime = endTime
        self.place = place
        self.isRecess = isRecess
        self.originalID = nil
    }

    init(from subject: Subject) {
        self.name = subject.name
        self.teacher = subject.teacher
        self.schedule = subject.schedule
        self.startTime = subject.startTime
        self.endTime = subject.endTime
        self.place = subject.place
        self.isRecess = subject.isRecess
        self.originalID = subject.persistentModelID
    }
}
