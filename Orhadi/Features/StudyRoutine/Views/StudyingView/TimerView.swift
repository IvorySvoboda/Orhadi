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
        var timeString: String {
            let minutes = Int(remainingTime) / 60
            let seconds = Int(remainingTime) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }

        return HStack {
            RollingTextView(text: timeString)
                .font(.system(size: 40, weight: .bold, design: .monospaced))
        }
    }
}
