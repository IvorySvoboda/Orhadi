//
//  DraftStudy.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 22/10/25.
//

import Foundation

struct DraftStudy {
    var name: String
    var studyDay: Date
    var studyTime: Date

    init(name: String, studyDay: Date, studyTime: Date) {
        self.name = name
        self.studyDay = studyDay
        self.studyTime = studyTime
    }

    init(from study: SRStudy) {
        self.name = study.name
        self.studyDay = study.studyDay
        self.studyTime = study.studyTime
    }
}
