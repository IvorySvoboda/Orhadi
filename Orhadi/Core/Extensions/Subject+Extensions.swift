//
//  Subject+Extensions.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 28/04/25.
//

import SwiftUI
import SwiftData

extension Subject {
    convenience init(from draft: DraftSubject) {
        self.init(
            name: draft.name.trimmingCharacters(in: .whitespaces),
            teacher: draft.teacher,
            schedule: draft.schedule,
            startTime: draft.startTime,
            endTime: draft.endTime,
            place: draft.place.trimmingCharacters(in: .whitespaces),
            isRecess: draft.isRecess
        )
    }

    func openMail() {
        guard let encoded = self.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let email = self.teacher?.email,
              let url = URL(string: "mailto:\(email)?subject=\(encoded)") else { return }
        UIApplication.shared.open(url)
    }
}
