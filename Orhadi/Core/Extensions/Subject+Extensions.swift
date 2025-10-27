//
//  Subject+Extensions.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 28/04/25.
//

import SwiftUI
import SwiftData

extension Subject {
    func openMail() {
        guard let encoded = self.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let email = self.teacher?.email,
              let url = URL(string: "mailto:\(email)?subject=\(encoded)") else { return }
        UIApplication.shared.open(url)
    }

    func hardDelete(in context: ModelContext) throws {
        withAnimation {
            context.delete(self)
        }
        try context.save()
    }

    func softDelete(in context: ModelContext) throws {
        withAnimation {
            isSubjectDeleted = true
            deletedAt = .now
        }
        try context.save()
    }

    func restore(in context: ModelContext) throws {
        withAnimation {
            isSubjectDeleted = false
            deletedAt = nil
        }
        try context.save()
    }
}
