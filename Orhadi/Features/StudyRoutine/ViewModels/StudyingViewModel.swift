import SwiftUI
import Observation

struct SessionItem: Identifiable {
    let id = UUID()
    let name: String
    var endTime: Date
    let isBreak: Bool
    let study: SRStudy?
}

@Observable class StudyingViewModel {
    // MARK: - Properties
    var game: GameManager?
    var user: UserProfile?

    var isReady: Bool = false
    var sessionItems: [SessionItem] = []
    var currentSessionIndex = 0
    @ObservationIgnored var timerManager = TimerManager()
    var isRunning: Bool = false
    var completedItems: [SessionItem] = []
    var studyFinished: Bool = false
    var pauseDate: Date?
    var breakTime: TimeInterval = 0

    private(set) var studies: [SRStudy] = []

    // MARK: - Computed Properties
    var currentStudyName: String {
        sessionItems[currentSessionIndex].name.nilIfEmpty() ?? String(localized: "Sem Nome")
    }

    var timeString: String {
        let minutes = Int(timerManager.remainingTime) / 60
        let seconds = Int(timerManager.remainingTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var filteredSessionItems: [SessionItem] {
        sessionItems.filter { item in
            item.id != sessionItems[currentSessionIndex].id
            && !completedItems.contains(where: { $0.id == item.id })
        }
    }

    // MARK: - Session Management
    func prepareSession(for studies: [SRStudy], with settings: Settings, gameManager: GameManager, user: UserProfile) {
        self.studies = studies
        self.game = gameManager
        self.user = user
        self.breakTime = settings.breakTime

        let sessionSequence = generateSessionSequence(for: studies, with: settings)
        self.isReady = true
        self.sessionItems = sessionSequence
        self.currentSessionIndex = 0
        self.isRunning = true

        if let firstEndTime = sessionSequence.first?.endTime {
            timerManager.start(with: firstEndTime)
        }
    }

    private func generateSessionSequence(for studies: [SRStudy], with settings: Settings) -> [SessionItem] {
        var sessionSequence: [SessionItem] = []
        var currentTime = Date()

        for (index, study) in studies.enumerated() {
            let studyDuration = study.studyTimeInSeconds
            let studyEnd = currentTime.addingTimeInterval(studyDuration)
            sessionSequence.append(SessionItem(name: study.name, endTime: studyEnd, isBreak: false, study: study))
            currentTime = studyEnd

            if index != studies.count - 1 {
                let breakEnd = currentTime.addingTimeInterval(settings.breakTime)
                sessionSequence.append(SessionItem(name: "Descanso", endTime: breakEnd, isBreak: true, study: nil))
                currentTime = breakEnd
            }
        }

        return sessionSequence
    }

    // MARK: - Session Progression
    func advanceSession() {
        guard currentSessionIndex < sessionItems.count else { return }
        let currentItem = sessionItems[currentSessionIndex]

        handleCompletedSession(currentItem)

        withAnimation {
            completedItems.append(currentItem)
        }

        currentSessionIndex += 1

        if currentSessionIndex < sessionItems.count {
            timerManager.start(with: sessionItems[currentSessionIndex].endTime)
        } else {
            endSession()
        }
    }

    func skipToNext() {
        guard currentSessionIndex < sessionItems.count else { return }

        let currentItem = sessionItems[currentSessionIndex]
        withAnimation {
            completedItems.append(currentItem)
        }

        adjustSessionTimes()

        currentSessionIndex += 1
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()

        if currentSessionIndex < sessionItems.count {
            timerManager.start(with: sessionItems[currentSessionIndex].endTime)
        } else {
            endSession()
        }
    }

    private func handleCompletedSession(_ currentItem: SessionItem) {
        guard !currentItem.isBreak, let study = currentItem.study else { return }

        updateLastStudied(for: study)
        awardGameXP(for: study)
    }

    private func updateLastStudied(for study: SRStudy) {
        if let index = studies.firstIndex(of: study) {
            studies[index].lastStudied = Date()
        }
    }

    private func awardGameXP(for study: SRStudy) {
        guard let game = game, let user = user else { return }

        let studyDurationInMinutes = study.studyTimeInMinutes
        game.addXP(50 * studyDurationInMinutes, to: user)
    }

    private func adjustSessionTimes() {
        let adjustment = sessionItems[currentSessionIndex].endTime.timeIntervalSinceNow
        sessionItems[currentSessionIndex].endTime = Date()

        for index in sessionItems.indices where index > currentSessionIndex {
            sessionItems[index].endTime -= adjustment
        }
    }

    private func endSession() {
        isRunning = false
        studyFinished = true
        timerManager.pause()
    }

    // MARK: - Time and Running State Management
    func handleTimeChange() {
        if timerManager.remainingTime <= 0 {
            advanceSession()
        }

        if let user, let game, isRunning, currentSessionIndex < sessionItems.count, !sessionItems[currentSessionIndex].isBreak {
            user.timeStudied += 1
            game.addXP(10, to: user)
        }
    }

    func handleRunningChange() {
        if isRunning {
            handleResumeSession()
        } else {
            pauseDate = Date()
            timerManager.pause()
        }
    }

    private func handleResumeSession() {
        if let pauseDate = pauseDate {
            let pauseDuration = Date().timeIntervalSince(pauseDate)
            sessionItems[currentSessionIndex].endTime += pauseDuration
        }
        pauseDate = nil
        timerManager.start(with: sessionItems[currentSessionIndex].endTime)
    }
}
