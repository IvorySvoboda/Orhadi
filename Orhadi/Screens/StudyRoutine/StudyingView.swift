//
//  StudyingView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 05/04/25.
//

import SwiftUI

protocol StudyItem: Identifiable {
    var name: String { get }
    var studyTime: Date { get }
    var lastStudied: Date { get set }
}

extension Subject: StudyItem {}
extension SRSubject: StudyItem {}

struct StudyingView<Subject: StudyItem & Equatable>: View {
    struct SessionItem: Identifiable {
        let id = UUID()
        let name: String
        var endTime: Date
        let isBreak: Bool
        let subject: Subject?
    }

    @Environment(\.colorScheme) private var colorScheme
    @Environment(Settings.self) private var settings

    @State private var isReady: Bool = false
    @State private var sessionItems: [SessionItem] = []
    @State private var currentSessionIndex = 0
    @State private var remainingTime: TimeInterval = 600
    @State private var countdownTimer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()
    @State private var isRunning: Bool = false
    @State private var completedSubjects: [Subject] = []
    @State private var studyFinished: Bool = false
    @State private var pauseDate: Date?

    @Binding var subjects: [Subject]

    var body: some View {
        ZStack {
            Color(OrhadiTheme.getBGColor(for: colorScheme))
                .ignoresSafeArea()

            VStack {
                Divider()

                HStack {
                    if currentSessionIndex < sessionItems.count {
                        Text(sessionItems[currentSessionIndex].name)
                    } else {
                        Text("Estudos completados! 🔥")
                    }
                    Spacer()
                }.padding(.leading)

                Divider()

                VStack {
                    TimerView(remainingTime: remainingTime)
                        .onReceive(countdownTimer) { _ in
                            tick()
                        }
                        .onChange(of: isRunning) { _, newValue in
                            if newValue {
                                if let pauseDate = pauseDate {
                                    let pauseDuration = Date().timeIntervalSince(pauseDate)
                                    sessionItems[currentSessionIndex].endTime += pauseDuration
                                }
                                countdownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
                            } else {
                                pauseDate = Date()
                                countdownTimer.upstream.connect().cancel()
                            }
                        }
                }
                .frame(height: 200)

                Divider()
                    .frame(height: 1)

                List {
                    if currentSessionIndex < sessionItems.count {
                        ForEach(
                            subjects.filter { !completedSubjects.contains($0) }
                        ) { subject in
                            if subject != sessionItems[currentSessionIndex].subject
                                ?? nil
                            {
                                HStack {
                                    Text(subject.name)
                                        .bold()
                                    Spacer()
                                    Text(formatHourAndMinute(subject.studyTime))
                                        .bold()
                                }
                                .frame(height: 35)
                                .modifier(ListRow())
                            }

                            if subject != subjects[subjects.count - 1] {
                                HStack {
                                    Text("Descanso").font(.system(size: 14))
                                    Spacer()
                                    Text(
                                        formatHourAndMinute(settings.breakTime)
                                    )
                                    .font(.system(size: 14))
                                }
                                .modifier(ListRow())
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .contentMargins(.top, -4)
                .background(OrhadiTheme.getBGColor(for: colorScheme))
                .environment(\.defaultMinListRowHeight, 20)
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
        .toolbarBackground(
            OrhadiTheme.getBGColor(for: colorScheme),
            for: .navigationBar
        )
        .onAppear {
            if !isReady {
                prepareSession()
            }
        }
    }

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
                let breakEnd = currentTime.addingTimeInterval(
                    settings.breakTime
                )
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
    }

    private func tick() {
        guard isRunning, currentSessionIndex < sessionItems.count else { return }

        let currentItem = sessionItems[currentSessionIndex]
        remainingTime = currentItem.endTime.timeIntervalSinceNow

        if remainingTime <= 0 {
            advanceSession()
        }
    }

    private func advanceSession() {
        let currentItem = sessionItems[currentSessionIndex]

        if !currentItem.isBreak, let subject = currentItem.subject {
            updateLastStudied(for: subject)
            withAnimation {
                completedSubjects.append(subject)
            }
        }

        currentSessionIndex += 1

        if currentSessionIndex < sessionItems.count {
            remainingTime = sessionItems[currentSessionIndex].endTime.timeIntervalSinceNow
        } else {
            isRunning = false
            studyFinished = true
        }
    }

    private func updateLastStudied(for subject: Subject) {
        if let index = subjects.firstIndex(of: subject) {
            subjects[index].lastStudied = Date()
        }
    }
}

struct ListRow: ViewModifier {
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

struct TimerView: View {

    var remainingTime: TimeInterval

    var body: some View {
        let digits = getDigits(
            from: max(0, Int(floor(remainingTime)))
        )

        HStack(spacing: -5) {
            RollingDigitView(digit: digits[0])
            RollingDigitView(digit: digits[1])
            Text(":")
                .font(
                    .system(
                        size: 30,
                        weight: .bold,
                        design: .monospaced
                    )
                )
                .padding(.horizontal, 2)
            RollingDigitView(digit: digits[2])
            RollingDigitView(digit: digits[3])
        }
    }

    private func getDigits(from seconds: Int) -> [Int] {
        let minutes = seconds / 60
        let seconds = seconds % 60
        let m1 = minutes / 10
        let m2 = minutes % 10
        let s1 = seconds / 10
        let s2 = seconds % 10
        return [m1, m2, s1, s2]
    }
}

struct RollingDigitView: View {
    let digit: Int
    @State private var previousDigit: Int = 0
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Text("\(previousDigit)")
                .font(.system(size: 30, weight: .bold, design: .monospaced))
                .offset(y: isAnimating ? -50 : 0)
                .opacity(isAnimating ? 0.1 : 1)
                .scaleEffect(isAnimating ? 0.2 : 1)
                .blur(radius: isAnimating ? 10 : 0)

            Text("\(digit)")
                .font(.system(size: 30, weight: .bold, design: .monospaced))
                .offset(y: isAnimating ? 0 : 50)
                .opacity(isAnimating ? 1 : 0.1)
                .scaleEffect(isAnimating ? 1 : 0)
                .blur(radius: isAnimating ? 0 : 10)
        }
        .frame(width: 30, height: 120)
        .clipped()
        .onChange(of: digit) { _, newValue in
            if newValue != previousDigit {
                withAnimation(.bouncy(duration: 0.5)) {
                    isAnimating = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    previousDigit = newValue
                    isAnimating = false
                }
            }
        }
        .onAppear {
            previousDigit = digit
        }
    }
}

#Preview {
    NavigationStack {
//        StudyingView(subjects: Subject.sampleData)
    }
    .environment(Settings())
}

