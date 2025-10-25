//
//  StudyingViewModel.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 22/10/25.
//

import Combine
import Observation
import SwiftUI
import SwiftData

extension StudyingView {
    @Observable class ViewModel {
        var context: ModelContext
        var studies: [SRStudy]
        var isReady: Bool = false
        var sessionItems: [SessionItem] = []
        var currentSessionIndex = 0
        var isRunning: Bool = false
        var studyFinished: Bool = false
        var breakTime: TimeInterval = 0

        var completedItems: [SessionItem] = []
        var pauseDate: Date?

        // MARK: - Timer Properties

        var remainingTime: TimeInterval = 0

        var cancellable: AnyCancellable?
        var endTime: Date?

        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

        // MARK: - Computed Helpers

        var currentStudyName: String {
            sessionItems[currentSessionIndex].name.nilIfEmpty() ?? String(localized: "No Name")
        }

        var timeString: String {
            let minutes = Int(remainingTime) / 60
            let seconds = Int(remainingTime) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }

        var filteredSessionItems: [SessionItem] {
            sessionItems.filter { item in
                item.id != sessionItems[currentSessionIndex].id
                && !completedItems.contains(where: { $0.id == item.id })
            }
        }

        init(studies: [SRStudy], breakTime: TimeInterval, context: ModelContext) {
            self.context = context
            self.studies = studies
            self.breakTime = breakTime
            prepareSession()
        }

        // MARK: - Timer Functions

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

        func tick() {
            guard let end = endTime else { return }
            let time = end.timeIntervalSinceNow

            self.remainingTime = time

            if time <= 0 {
                cancellable?.cancel()
                self.remainingTime = 0
            }
        }

        // MARK: - Studying Functions

        func prepareSession() {
            let sessionSequence = generateSessionSequence(for: studies)
            isReady = true
            sessionItems = sessionSequence
            currentSessionIndex = 0
            isRunning = true

            if let firstEndTime = sessionSequence.first?.endTime {
                start(with: firstEndTime)
            }
        }

        func generateSessionSequence(for studies: [SRStudy]) -> [SessionItem] {
            var sessionSequence: [SessionItem] = []
            var currentTime = Date()

            for (index, study) in studies.enumerated() {
                let studyDuration = study.studyTimeInSeconds
                let studyEnd = currentTime.addingTimeInterval(studyDuration)
                sessionSequence.append(SessionItem(name: study.name, endTime: studyEnd, isBreak: false, study: study))
                currentTime = studyEnd

                if index != studies.count - 1 {
                    let breakEnd = currentTime.addingTimeInterval(breakTime)
                    sessionSequence.append(SessionItem(name: String(localized: "Interval"), endTime: breakEnd, isBreak: true, study: nil))
                    currentTime = breakEnd
                }
            }

            return sessionSequence
        }

        // MARK: Session Progression

        func advanceSession() {
            /// Proteje o app de "crashar" por `out of range`
            /// verificando se o index atual é menor que a
            /// quantidade de itens na seção atual.
            guard currentSessionIndex < sessionItems.count else { return }

            /// Define o item atual.
            let currentItem = sessionItems[currentSessionIndex]

            /// Completa o item atual.
            handleCompletedSession(currentItem)

            /// Coloca o item atual pra os itens completados.
            withAnimation {
                completedItems.append(currentItem)
            }

            /// Avança para o proximo item.
            currentSessionIndex += 1

            /// Se o index for menor que a quantidade
            /// de itens em `sessionItems`, continua
            /// os estudos normalmente, atualizando o
            /// timer, se não, termina a seção.
            if currentSessionIndex < sessionItems.count {
                start(with: sessionItems[currentSessionIndex].endTime)
            } else {
                endSession()
            }
        }

        func skipToNext() {
            /// Proteje o app de "crashar" por `out of range`
            /// verificando se o index atual é menor que a
            /// quantidade de itens na seção atual.
            guard currentSessionIndex < sessionItems.count else { return }

            /// Define o item atual.
            let currentItem = sessionItems[currentSessionIndex]

            /// Coloca o item atual nos itens completados.
            withAnimation {
                completedItems.append(currentItem)
            }

            /// Ajusta o tempo da seção ja que o item foi pulado.
            adjustSessionTimes()

            /// avança para o proximo item
            currentSessionIndex += 1

            UIImpactFeedbackGenerator(style: .soft).impactOccurred()

            /// Se o index for menor que a quantidade
            /// de itens em `sessionItems`, continua
            /// os estudos normalmente, atualizando o
            /// timer, se não, termina a seção.
            if currentSessionIndex < sessionItems.count {
                start(with: sessionItems[currentSessionIndex].endTime)
                if !isRunning {
                    isRunning.toggle()
                }
            } else {
                endSession()
            }
        }

        func handleCompletedSession(_ currentItem: SessionItem) {
            guard !currentItem.isBreak, let study = currentItem.study else { return }
            try? study.updateLastStudied(in: context)
        }

        func adjustSessionTimes() {
            let adjustment = sessionItems[currentSessionIndex].endTime.timeIntervalSinceNow
            sessionItems[currentSessionIndex].endTime = Date()

            for index in sessionItems.indices where index > currentSessionIndex {
                sessionItems[index].endTime -= adjustment
            }
        }

        func endSession() {
            isRunning = false
            studyFinished = true
            start(with: .now)
            pause()
        }

        // MARK: Time and Running State Management

        func handleTimeChange() {
            if remainingTime <= 0 {
                advanceSession()
            }
        }

        func handleRunningChange() {
            if isRunning {
                handleResumeSession()
            } else {
                pauseDate = Date()
                pause()
            }
        }

        func handleResumeSession() {
            if let pauseDate = pauseDate {
                let pauseDuration = Date().timeIntervalSince(pauseDate)
                sessionItems[currentSessionIndex].endTime += pauseDuration
            }
            pauseDate = nil
            start(with: sessionItems[currentSessionIndex].endTime)
        }

        func stopStudying() {
            isReady = false
            sessionItems = []
            currentSessionIndex = 0
            isRunning = false
            completedItems = []
            studyFinished = false
            pauseDate = nil
            breakTime = 0
            cancellable?.cancel()
            remainingTime = 0
            endTime = nil
        }
    }
}
