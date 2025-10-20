//
//  Subject+Extensions.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 28/04/25.
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

    static let sampleData = [
        Subject(
            name: "English",
            teacher: Teacher(name: "Ana Lima", email: "ana.lima@example.com"),
            schedule: Date(),
            startTime: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!,
            endTime: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!,
            place: "Sala 109",
            isRecess: false
        ),
        Subject(
            name: "Matemática",
            teacher: Teacher(name: "Carlos Mendes", email: "carlos.mendes@example.com"),
            schedule: Date(),
            startTime: Calendar.current.date(bySettingHour: 9, minute: 15, second: 0, of: Date())!,
            endTime: Calendar.current.date(bySettingHour: 10, minute: 15, second: 0, of: Date())!,
            place: "Sala 202",
            isRecess: false
        ),
        Subject(
            name: "",
            teacher: nil,
            schedule: Date(),
            startTime: Calendar.current.date(bySettingHour: 10, minute: 15, second: 0, of: Date())!,
            endTime: Calendar.current.date(bySettingHour: 10, minute: 30, second: 0, of: Date())!,
            place: "",
            isRecess: true
        ),
        Subject(
            name: "História",
            teacher: Teacher(name: "Beatriz Rocha", email: "beatriz.rocha@example.com"),
            schedule: Date(),
            startTime: Calendar.current.date(bySettingHour: 10, minute: 30, second: 0, of: Date())!,
            endTime: Calendar.current.date(bySettingHour: 11, minute: 30, second: 0, of: Date())!,
            place: "Sala 105",
            isRecess: false
        )
    ]

    func delete() {
        withAnimation {
            isSubjectDeleted = true
            deletedAt = .now
        }
    }

    func restore() {
        withAnimation {
            isSubjectDeleted = false
            deletedAt = nil
        }
    }
}
