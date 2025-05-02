//
//  StudyingView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 05/04/25.
//

import SwiftUI

struct SessionItem: Identifiable {
    let id = UUID()
    let name: String
    var endTime: Date
    let isBreak: Bool
    let study: SRStudy?
}

struct StudyingView: View {
    @Environment(Settings.self) private var settings
    @Environment(UserProfile.self) private var user
    @Environment(GameManager.self) private var game

    // MARK: - Properties

    @State private var timerManager = TimerManager()
    @State private var isReady: Bool = false
    @State private var sessionItems: [SessionItem] = []
    @State private var currentSessionIndex = 0
    @State private var isRunning: Bool = false
    @State private var completedItems: [SessionItem] = []
    @State private var studyFinished: Bool = false
    @State private var pauseDate: Date?
    @State private var breakTime: TimeInterval = 0

    @Binding var studies: [SRStudy]

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

    // MARK: - Views

    var body: some View {
        ZStack {
            Color.orhadiBG
                .ignoresSafeArea()

            VStack {
                header
                Divider()
                timerSection
                Divider()
                nextSubjectsList
            }
        }
        .navigationTitle("Estudando")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                playPauseButton
            }
        }
        .toolbarBackground(.orhadiBG, for: .navigationBar)
        .disableIdleTimer()
        .onAppear {
            if !isReady {
                prepareSession(for: studies)
            }
        }
    }

    // MARK: - Header
    private var header: some View {
        Group {
            Divider()
            HStack {
                if currentSessionIndex < sessionItems.count {
                    Text(currentStudyName)
                        .lineLimit(1)
                        .frame(width: 200, alignment: .leading)
                } else {
                    Text("Estudos completados! 🔥")
                }
                Spacer()
                skipButton
            }
            .padding(.horizontal)
            .offset(y: 2)
        }
    }

    // MARK: - Play/Pause Button
    private var playPauseButton: some View {
        Button {
            isRunning.toggle()
        } label: {
            if isRunning && !studyFinished {
                Image(systemName: "pause.circle.fill")
                    .font(.title2)
            } else {
                Image(systemName: "play.circle.fill")
                    .font(.title2)
            }
        }
        .disabled(studyFinished)
    }

    // MARK: - Skip Button
    private var skipButton: some View {
        Button {
            skipToNext()
        } label: {
            Image(systemName: "forward.fill")
        }
        .tint(.font)
        .disabled(studyFinished)
    }

    // MARK: - Timer Section
    private var timerSection: some View {
        VStack {
            HStack {
                RollingTextView(text: timeString)
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
            }
            .onChange(of: timerManager.remainingTime) { _, _ in
                handleTimeChange()
            }
            .onChange(of: isRunning) { _, newValue in
                handleRunningChange()
            }
        }
        .frame(height: 200)
    }

    // MARK: - Next Subjects List
    private var nextSubjectsList: some View {
        List {
            if currentSessionIndex < sessionItems.count {
                ForEach(filteredSessionItems) { sessionItem in
                    sessionRow(for: sessionItem)
                }
            }
        }
        .listStyle(.plain)
        .contentMargins(.top, -4)
        .background(.orhadiBG)
        .environment(\.defaultMinListRowHeight, 20)
    }

    private func sessionRow(for sessionItem: SessionItem) -> some View {
        Group {
            if sessionItem.isBreak {
                breakSessionRow
            } else if let study = sessionItem.study {
                studySessionRow(for: study)
            }
        }
    }

    private var breakSessionRow: some View {
        HStack {
            Text("Descanso")
            Spacer()
            Text(breakTime.formatToHour())
        }
        .font(.system(size: 14))
        .foregroundStyle(Color.secondary)
        .plainListRow()
    }

    private func studySessionRow(for study: SRStudy) -> some View {
        HStack {
            Text(study.name.isEmpty ? "Sem Nome" : study.name)
                .bold()
            Spacer()
            Text(study.studyTime.formatToHour())
                .bold()
        }
        .frame(height: 35)
        .plainListRow()
    }

    // MARK: - Actions

    // MARK: Session Management
    private func prepareSession(for studies: [SRStudy]) {
        self.studies = studies
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

    // MARK: Session Progression
    private func advanceSession() {
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
            timerManager.start(with: sessionItems[currentSessionIndex].endTime)
        } else {
            endSession()
        }
    }

    private func skipToNext() {
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

    // MARK: Time and Running State Management
    private func handleTimeChange() {
        if timerManager.remainingTime <= 0 {
            advanceSession()
        }

        if isRunning, currentSessionIndex < sessionItems.count, !sessionItems[currentSessionIndex].isBreak {
            user.timeStudied += 1
            game.addXP(10, to: user)
        }
    }

    private func handleRunningChange() {
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
