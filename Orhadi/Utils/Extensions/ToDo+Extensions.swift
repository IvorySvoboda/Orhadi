//
//  ToDo+Extensions.swift
//  Orhadi
//
//  Created by Zyvoxi . on 22/04/25.
//

import Foundation

extension ToDo {
    func scheduleNotification() {
        let todo = self

        if let oneHourBefore = Calendar.current.date(
            byAdding: .hour, value: -1, to: todo.dueDate
        ) {
            NotificationsManager.shared.addNotification(
                identifier: "\(todo.id)-1h",
                title: todo.title,
                body: String(localized: "Falta 1 hora para a tarefa expirar."),
                date: oneHourBefore
            )
        }

        if let twentyFourHoursBefore = Calendar.current.date(
            byAdding: .hour, value: -24, to: todo.dueDate
        ) {
            NotificationsManager.shared.addNotification(
                identifier: "\(todo.id)-24h",
                title: todo.title,
                body: String(localized: "Falta 1 dia para a tarefa expirar."),
                date: twentyFourHoursBefore
            )
        }

        NotificationsManager.shared.addNotification(
            identifier: "\(todo.id)-due",
            title: String(localized: "A Tarefa Venceu!"),
            body: String(localized: "A Tarefa: \(todo.title) Venceu!"),
            date: todo.dueDate
        )
    }
}
