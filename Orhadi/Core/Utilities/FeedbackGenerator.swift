//
//  FeedbackGenerator.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 29/10/25.
//

import UIKit

class FeedbackGenerator {
    func notificationOccurred(_ notificationType: UINotificationFeedbackGenerator.FeedbackType) {
        #if !DEBUG
        FeedbackGenerator().notificationOccurred(notificationType)
        #endif
    }
}
