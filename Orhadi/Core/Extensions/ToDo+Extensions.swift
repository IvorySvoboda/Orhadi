//
//  ToDo+Extensions.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 22/04/25.
//

import SwiftUI
import SwiftData
import WidgetKit

extension ToDo {
    convenience init(from draft: DraftToDo) {
        self.init(
            title: draft.title.trimmingCharacters(in: .whitespaces),
            info: draft.info,
            dueDate: draft.dueDate,
            withHour: draft.withHour,
            priority: draft.priority
        )
    }

    var identifiers: [String] {[
        "\(self.id)-1h",
        "\(self.id)-24h",
        "\(self.id)-due"
    ]}

    func scheduleNotification() {
        if let oneHourBefore = Calendar.current.date(
            byAdding: .hour,
            value: -1,
            to: dueDate
        ) {
            NotificationsManager.shared.addNotification(
                identifier: "\(id)-1h",
                title: title,
                body: String(localized: "1 hour left until the to-do’s deadline."),
                date: oneHourBefore)
        }

        if let twentyFourHoursBefore = Calendar.current.date(
            byAdding: .hour,
            value: -24,
            to: dueDate
        ) {
            NotificationsManager.shared.addNotification(
                identifier: "\(id)-24h",
                title: title,
                body: String(localized: "1 day left until the to-do’s deadline."),
                date: twentyFourHoursBefore)
        }

        NotificationsManager.shared.addNotification(
            identifier: "\(id)-due",
            title: String(localized: "The to-do is overdue!"),
            body: String(localized: "The to-do: \(title) is overdue!"),
            date: dueDate)
    }

    var formattedDueDate: String {
        let calendar = Calendar.current
        let now = Date()

        guard let twoDaysAhead = calendar.date(byAdding: .day, value: 2, to: now),
              let twoDaysAgo = calendar.date(byAdding: .day, value: -3, to: now) else {
            return ""
        }

        let formatter = DateFormatter()

        if dueDate > twoDaysAhead || dueDate <= twoDaysAgo {
            formatter.dateFormat = withHour ? "dd/MM/yyyy, HH:mm" : "dd/MM/yyyy"
        } else {
            formatter.timeStyle = withHour ? .short : .none
            formatter.dateStyle = .medium
            formatter.doesRelativeDateFormatting = true
        }

        return formatter.string(from: dueDate)
    }
}
