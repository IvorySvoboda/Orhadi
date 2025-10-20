//
//  StudyingView.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 05/04/25.
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
    @Environment(\.dismiss) private var dismiss
    @Environment(Settings.self) private var settings

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
        sessionItems[currentSessionIndex].name.nilIfEmpty() ?? String(localized: "No Name")
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
                nextSubjectsList
            }
        }
        .statusBarHidden(isRunning)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Label("Stop Studying", systemImage: "chevron.backward")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                playPauseButton
            }
            ToolbarItem(placement: .topBarTrailing) {
                skipButton
            }
        }
        .toolbarBackground(.orhadiBG, for: .navigationBar)
        .toolbarVisibility(.hidden, for: .tabBar)
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
                    Text("All studies completed! 🔥")
                }
                Spacer()
            }
            .padding(.horizontal)
            .offset(y: 2)
        }
    }

    // MARK: - Play/Pause Button
    private var playPauseButton: some View {
        Button(action: { isRunning.toggle() }) {
            if isRunning && !studyFinished {
                Label("Pause", systemImage: "pause")
            } else {
                Label("Play", systemImage: "play.fill")
            }
        }
        .tint(.accentColor)
        .disabled(studyFinished)
    }

    // MARK: - Skip Button
    private var skipButton: some View {
        Button(action: skipToNext) {
            Label("Next", systemImage: "forward.fill")
        }
        .tint(.accentColor)
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
            .onChange(of: isRunning) { _, _ in
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
            Text("Interval")
            Spacer()
            Text(breakTime.durationString())
        }
        .font(.system(size: 14))
        .foregroundStyle(Color.secondary)
        .plainListRow()
    }

    private func studySessionRow(for study: SRStudy) -> some View {
        HStack {
            Text(study.name.isEmpty ? "No Name" : study.name)
                .bold()
            Spacer()
            Text(study.studyTimeInSeconds.durationString())
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
                sessionSequence.append(SessionItem(name: "Interval", endTime: breakEnd, isBreak: true, study: nil))
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
            if !isRunning {
                isRunning.toggle()
            }
        } else {
            endSession()
        }
    }

    private func handleCompletedSession(_ currentItem: SessionItem) {
        guard !currentItem.isBreak, let study = currentItem.study else { return }

        updateLastStudied(for: study)
    }

    private func updateLastStudied(for study: SRStudy) {
        if let index = studies.firstIndex(of: study) {
            studies[index].lastStudied = Date()
        }
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
        timerManager.start(with: .now)
        timerManager.pause()
    }

    // MARK: Time and Running State Management
    private func handleTimeChange() {
        if timerManager.remainingTime <= 0 {
            advanceSession()
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
