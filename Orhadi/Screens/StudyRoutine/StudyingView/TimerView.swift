//
//  TimerView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 21/04/25.
//

import SwiftUI

struct TimerView: View {
    var remainingTime: TimeInterval

    var body: some View {
        let timeString = getFormattedTime(from: remainingTime)

        return HStack(spacing: -5) {
            RollingTextView(text: timeString)
                .font(.system(size: 40, weight: .bold, design: .monospaced))
        }
    }

    private func getFormattedTime(from time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
