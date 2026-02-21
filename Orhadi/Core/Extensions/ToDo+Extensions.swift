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
}
