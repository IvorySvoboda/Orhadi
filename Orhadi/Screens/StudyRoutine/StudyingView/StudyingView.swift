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
    let subject: SRStudy?
}

struct StudyingView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(OrhadiTheme.self) private var theme
    @Environment(Settings.self) private var settings
    @Environment(UserProfile.self) private var user
    @Environment(GameManager.self) private var game

    @State private var isReady: Bool = false
    @State private var sessionItems: [SessionItem] = []
    @State private var currentSessionIndex = 0
    @State private var remainingTime: TimeInterval = 0
    @StateObject private var timerManager = TimerManager()
    @State private var isRunning: Bool = false
    @State private var completedItems: [SessionItem] = []
    @State private var studyFinished: Bool = false
    @State private var pauseDate: Date?
    @State private var breakTime: TimeInterval = 0

    @Binding var subjects: [SRStudy]

    // MARK: - Views

    var body: some View {
        ZStack {
            Color(theme.bgColor())
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
                Button(action: {
                    isRunning.toggle()
                }) {
                    if isRunning && !studyFinished {
                        Image(systemName: "pause.circle.fill")
                            .font(.title2)
                    } else {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                    }
                }.disabled(studyFinished)
            }
        }
        .toolbarBackground(theme.bgColor(), for: .navigationBar)
        .onAppear {
            if !isReady {
                prepareSession()
            }
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }

    private var header: some View {
        Group {
            Divider()
            HStack {
                if currentSessionIndex < sessionItems.count {
                    Text(sessionItems[currentSessionIndex].name.nilIfEmpty() ?? String(localized: "Sem Nome"))
                        .lineLimit(1)
                        .frame(width: 200, alignment: .leading)
                } else {
                    Text("Estudos completados! 🔥")
                }
                Spacer()
                Button {
                    skipToNext()
                } label: {
                    Image(systemName: "forward.fill")
                }
                .tint(colorScheme == .dark ? .white : .black)
                .disabled(studyFinished)
            }.padding(.horizontal).offset(y: 2)
        }
    }

    private var timerSection: some View {
        VStack {
            TimerView(remainingTime: timerManager.remainingTime)
                .onChange(of: timerManager.remainingTime) { _, newValue in
                    remainingTime = newValue

                    if newValue <= 0 {
                        advanceSession()
                    }

                    if isRunning, currentSessionIndex < sessionItems.count, !sessionItems[currentSessionIndex].isBreak {
                        user.timeStudied += 1
                        game.addXP(10, to: user)
                    }
                }
                .onChange(of: isRunning) { _, newValue in
                    if newValue {
                        if let pauseDate = pauseDate {
                            let pauseDuration = Date().timeIntervalSince(pauseDate)
                            sessionItems[currentSessionIndex].endTime += pauseDuration
                        }
                        pauseDate = nil
                        timerManager.start(with: sessionItems[currentSessionIndex].endTime)
                    } else {
                        pauseDate = Date()
                        timerManager.pause()
                    }
                }
        }.frame(height: 200)
    }

    private var nextSubjectsList: some View {
        List {
            if currentSessionIndex < sessionItems.count {
                ForEach(
                    sessionItems.filter { item in
                        item.id != sessionItems[currentSessionIndex].id &&
                        !completedItems.contains(where: { $0.id == item.id })
                    }
                ) { sessionItem in
                    if sessionItem.isBreak {
                        HStack {
                            Text("Descanso")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.secondary)
                            Spacer()
                            Text(
                                formatHourAndMinute(breakTime)
                            )
                            .font(.system(size: 14))
                            .foregroundStyle(Color.secondary)
                        }
                        .modifier(ListRowModifier())
                    } else if let subject = sessionItem.subject {
                        HStack {
                            Text(subject.name.isEmpty ? "Sem Nome" : subject.name)
                                .bold()
                            Spacer()
                            Text(formatHourAndMinute(subject.studyTime))
                                .bold()
                        }
                        .frame(height: 35)
                        .modifier(ListRowModifier())
                    }
                }
            }
        }
        .listStyle(.plain)
        .contentMargins(.top, -4)
        .background(theme.bgColor())
        .environment(\.defaultMinListRowHeight, 20)
    }

    // MARK: - Functions

    private func prepareSession() {
        var sessionSequence: [SessionItem] = []
        var currentTime = Date()

        for (index, subject) in subjects.enumerated() {
            let components = Calendar.current.dateComponents(
                [.hour, .minute],
                from: subject.studyTime
            )
            let hours = components.hour ?? 0
            let minutes = components.minute ?? 0

            let studyDuration = TimeInterval(hours * 3600 + minutes * 60)

            let studyEnd = currentTime.addingTimeInterval(studyDuration)
            sessionSequence.append(
                SessionItem(
                    name: subject.name,
                    endTime: studyEnd,
                    isBreak: false,
                    subject: subject
                )
            )
            currentTime = studyEnd

            if index != subjects.count - 1 {
                let breakEnd = currentTime.addingTimeInterval(settings.breakTime)
                sessionSequence.append(
                    SessionItem(
                        name: "Descanso",
                        endTime: breakEnd,
                        isBreak: true,
                        subject: nil
                    )
                )
                currentTime = breakEnd
            }
        }

        isReady = true
        sessionItems = sessionSequence
        currentSessionIndex = 0
        remainingTime = sessionSequence.first?.endTime.timeIntervalSinceNow ?? 0
        isRunning = true
        breakTime = settings.breakTime

        if let firstEndTime = sessionSequence.first?.endTime {
            timerManager.start(with: firstEndTime)
        }
    }

    private func advanceSession() {
        guard currentSessionIndex < sessionItems.count else { return }
        let currentItem = sessionItems[currentSessionIndex]

        if !currentItem.isBreak, let subject = currentItem.subject {
            updateLastStudied(for: subject)
            let components = Calendar.current.dateComponents([.hour, .minute], from: subject.studyTime)
            game.addXP(50 * (((components.hour ?? 0) * 60) + (components.minute ?? 0)), to: user)
        }

        withAnimation {
            completedItems.append(currentItem)
        }

        currentSessionIndex += 1

        if currentSessionIndex < sessionItems.count {
            timerManager.start(with: sessionItems[currentSessionIndex].endTime)
        } else {
            isRunning = false
            studyFinished = true
            timerManager.pause()
        }
    }

    private func skipToNext() {
        guard currentSessionIndex < sessionItems.count else { return }

        let currentItem = sessionItems[currentSessionIndex]

        withAnimation {
            completedItems.append(currentItem)
        }

        let adjustment = sessionItems[currentSessionIndex].endTime.timeIntervalSinceNow
        sessionItems[currentSessionIndex].endTime = Date()

        for index in sessionItems.indices where index > currentSessionIndex {
            sessionItems[index].endTime -= adjustment
        }

        currentSessionIndex += 1

        UIImpactFeedbackGenerator(style: .soft).impactOccurred()

        if currentSessionIndex < sessionItems.count {
            timerManager.start(with: sessionItems[currentSessionIndex].endTime)
        } else {
            isRunning = false
            studyFinished = true
            timerManager.pause()
        }
    }

    private func updateLastStudied(for subject: SRStudy) {
        if let index = subjects.firstIndex(of: subject) {
            subjects[index].lastStudied = Date()
        }
    }
}

struct ListRowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .listRowBackground(Color.clear)
            .listRowInsets(
                EdgeInsets(
                    top: -1,
                    leading: 0,
                    bottom: 0,
                    trailing: 0
                )
            )
            .alignmentGuide(.listRowSeparatorLeading) {
                viewDimensions in
                return 0
            }
    }
}
