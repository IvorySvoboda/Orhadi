//
//  TimerManager.swift
//  Orhadi
//
//  Created by Zyvoxi . on 21/04/25.
//

import Foundation
import Combine
import Observation

@Observable class TimerManager {
    var remainingTime: TimeInterval = 0

    private var cancellable: AnyCancellable?
    private var endTime: Date?

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    func start(with endTime: Date) {
        self.endTime = endTime
        self.remainingTime = endTime.timeIntervalSinceNow

        cancellable?.cancel()
        cancellable = timer.sink { [weak self] _ in
            self?.tick()
        }
    }

    func pause() {
        cancellable?.cancel()
    }

    private func tick() {
        guard let end = endTime else { return }
        let time = end.timeIntervalSinceNow

        self.remainingTime = time

        if time <= 0 {
            cancellable?.cancel()
            self.remainingTime = 0
        }
    }

    deinit {
        cancellable?.cancel()
        self.remainingTime = 0
    }
}
