//
//  NotificationsManager.swift
//  Orhadi
//
//  Created by Zyvoxi . on 04/04/25.
//

import Foundation
import UserNotifications

class NotificationsManager {

    static let shared = NotificationsManager()

    private let center = UNUserNotificationCenter.current()

    func requestNotificationAuthorization() {
        center.requestAuthorization(
            options: [.alert, .sound, .badge]) { granted, _ in
                if !granted {
                    print("Notificações desativadas!")
                }
            }
    }

    func notificationStatus(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { (settings) in
            let authorized = settings.authorizationStatus == .authorized
            completion(authorized)
        }
    }

    func removePendingNotifications(withIdentifiers identifiers: [String]) {
        debugPrint(
            "Removendo notificações com os seguintes identifiers: \(identifiers)"
        )

        center.removePendingNotificationRequests(
            withIdentifiers: identifiers
        )
    }

    func addNotification(
        identifier: String,
        title: String,
        body: String,
        date: Date
    ) {
        guard date > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: triggerDate,
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print(
                    "Erro ao agendar notificação: \(error.localizedDescription)"
                )
            } else {
                debugPrint("Notificação agendada para: \(identifier)")
            }
        }
    }

}
