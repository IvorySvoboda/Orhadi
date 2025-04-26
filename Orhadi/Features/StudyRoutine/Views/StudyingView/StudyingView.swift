//
//  StudyingView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 05/04/25.
//

import SwiftUI

struct StudyingView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(Settings.self) private var settings
    @Environment(UserProfile.self) private var user
    @Environment(GameManager.self) private var game

    @State var viewModel = StudyingViewModel()
    @Binding var studies: [SRStudy]

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
            if !viewModel.isReady {
                viewModel.prepareSession(
                    for: studies,
                    with: settings,
                    gameManager: game,
                    user: user
                )
            }
        }
    }

    // MARK: - Header
    private var header: some View {
        Group {
            Divider()
            HStack {
                if viewModel.currentSessionIndex < viewModel.sessionItems.count {
                    Text(viewModel.currentStudyName)
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
            viewModel.isRunning.toggle()
        } label: {
            if viewModel.isRunning && !viewModel.studyFinished {
                Image(systemName: "pause.circle.fill")
                    .font(.title2)
            } else {
                Image(systemName: "play.circle.fill")
                    .font(.title2)
            }
        }
        .disabled(viewModel.studyFinished)
    }

    // MARK: - Skip Button
    private var skipButton: some View {
        Button {
            viewModel.skipToNext()
        } label: {
            Image(systemName: "forward.fill")
        }
        .tint(colorScheme == .dark ? .white : .black)
        .disabled(viewModel.studyFinished)
    }

    // MARK: - Timer Section
    private var timerSection: some View {
        VStack {
            HStack {
                RollingTextView(text: viewModel.timeString)
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
            }
            .onChange(of: viewModel.timerManager.remainingTime) { _, _ in
                viewModel.handleTimeChange()
            }
            .onChange(of: viewModel.isRunning) { _, newValue in
                viewModel.handleRunningChange()
            }
        }
        .frame(height: 200)
    }

    // MARK: - Next Subjects List
    private var nextSubjectsList: some View {
        List {
            if viewModel.currentSessionIndex < viewModel.sessionItems.count {
                ForEach(viewModel.filteredSessionItems) { sessionItem in
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
            Text(formatHourAndMinute(viewModel.breakTime))
        }
        .font(.system(size: 14))
        .foregroundStyle(Color.secondary)
        .modifier(ListRowModifier())
    }

    private func studySessionRow(for study: SRStudy) -> some View {
        HStack {
            Text(study.name.isEmpty ? "Sem Nome" : study.name)
                .bold()
            Spacer()
            Text(formatHourAndMinute(study.studyTime))
                .bold()
        }
        .frame(height: 35)
        .modifier(ListRowModifier())
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
            .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in 0 }
    }
}
