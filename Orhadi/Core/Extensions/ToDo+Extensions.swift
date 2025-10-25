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

    static let sampleData: [ToDo] = [
        .init(
            title: "Comprar material de arte",
            info: "Tintas, pincéis e papéis para o projeto de pintura",
            dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
            withHour: false,
            createdAt: Date(),
            isCompleted: false,
            priority: .medium,
            isArchived: false
        ),
        .init(
            title: "Enviar relatório mensal",
            info: "Relatório de desempenho para o gestor",
            dueDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            withHour: true,
            createdAt: Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date(),
            isCompleted: true,
            completedAt: Calendar.current.date(byAdding: .day, value: -1, to: Date()),
            priority: .high,
            isArchived: false
        ),
        .init(
            title: "Ligar para fornecedor",
            info: "Negociar valores para a próxima remessa",
            dueDate: Calendar.current.date(byAdding: .hour, value: 5, to: Date()) ?? Date(),
            withHour: true,
            createdAt: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            isCompleted: false,
            priority: .low,
            isArchived: false
        ),
        .init(
            title: "Study SwiftUI avançado",
            info: "Terminar curso sobre animações e performance",
            dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
            withHour: false,
            createdAt: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
            isCompleted: false,
            priority: .medium,
            isArchived: false
        ),
        .init(
            title: "Organizar documentos antigos",
            info: "Separar documentos para arquivar",
            dueDate: Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date(),
            withHour: false,
            createdAt: Calendar.current.date(byAdding: .day, value: -40, to: Date()) ?? Date(),
            isCompleted: true,
            completedAt: Calendar.current.date(byAdding: .day, value: -29, to: Date()),
            priority: .none,
            isArchived: true
        )
    ]

    func toggleCompleted(in context: ModelContext, scheduleNotifications: Bool = false) throws {
        /// Se a to-dos não estiver completada
        if !isCompleted {
            /// completa a tarefa.
            withAnimation {
                isCompleted = true
                completedAt = .now
            }

            /// remove as notificações agendadas
            NotificationsManager.shared.removePendingNotifications(withIdentifiers: identifiers)
        } else {
            /// descompleta a tarefa.
            withAnimation {
                isCompleted = false
                completedAt = nil
            }

            /// Agenda as notificações novamente, sempre respeitando as preferências do usuário.
            if scheduleNotifications {
                scheduleNotification()
            }
        }

        try context.save()
    }

    func hardDelete(in context: ModelContext) throws {
        NotificationsManager.shared.removePendingNotifications(withIdentifiers: identifiers)

        withAnimation {
            context.delete(self)
        }

        try context.save()
    }

    func softDelete(in context: ModelContext) throws {
        NotificationsManager.shared.removePendingNotifications(withIdentifiers: identifiers)

        withAnimation {
            isToDoDeleted = true
            deletedAt = .now
        }

        try context.save()
    }

    func restore(in context: ModelContext, scheduleNotifications: Bool = false) throws {
        if !isCompleted, dueDate > .now, !isArchived, scheduleNotifications {
            scheduleNotification()
        }

        withAnimation {
            isToDoDeleted = false
            deletedAt = nil
        }

        try context.save()
    }

    func archive(in context: ModelContext) throws {
        NotificationsManager.shared.removePendingNotifications(withIdentifiers: identifiers)

        withAnimation { isArchived = true }

        try context.save()
    }

    func unarchive(in context: ModelContext, scheduleNotifications: Bool = false) throws {
        if !isCompleted, dueDate > .now, scheduleNotifications {
            scheduleNotification()
        }

        withAnimation { isArchived = false }

        try context.save()
    }
}
