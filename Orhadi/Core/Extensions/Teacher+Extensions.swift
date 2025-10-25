//
//  Teacher+Extensions.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 28/04/25.
//

import SwiftUI
import SwiftData

extension Teacher {
    func openMail() {
        guard let url = URL(string: "mailto:\(self.email)") else { return }
        UIApplication.shared.open(url)
    }

    func hardDelete(in context: ModelContext) throws {
        withAnimation {
            context.delete(self)
        }
        try context.save()
    }
}
