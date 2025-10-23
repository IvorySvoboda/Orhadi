//
//  StudyingView.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 05/04/25.
//

import SwiftUI

struct StudyingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Settings.self) private var settings

    @Binding var studies: [SRStudy]
    @State private var viewModel = ViewModel()

    // MARK: - Views

    var body: some View {
        VStack {
            Divider()

            HStack {
                if viewModel.currentSessionIndex < viewModel.sessionItems.count {
                    Text(viewModel.currentStudyName)
                        .lineLimit(1)
                        .frame(width: 200, alignment: .leading)
                } else {
                    Text("All studies completed! 🔥")
                }
                Spacer()
            }
            .padding(.horizontal)
            .offset(y: 2)

            Divider()

            VStack {
                HStack {
                    RollingTextView(text: viewModel.timeString)
                        .font(.system(size: 40, weight: .bold, design: .monospaced))
                }
                .onChange(of: viewModel.remainingTime) { _, _ in
                    viewModel.handleTimeChange()
                }
                .onChange(of: viewModel.isRunning) { _, _ in
                    viewModel.handleRunningChange()
                }
            }.frame(height: 200)

            List {
                if viewModel.currentSessionIndex < viewModel.sessionItems.count {
                    ForEach(viewModel.filteredSessionItems) { sessionItem in
                        if sessionItem.isBreak {
                            HStack {
                                Text("Interval")
                                Spacer()
                                Text(viewModel.breakTime.durationString())
                            }
                            .font(.system(size: 14))
                            .foregroundStyle(Color.secondary)
                            .plainListRow()
                        } else if let study = sessionItem.study {
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

                    }
                }
            }
            .listStyle(.plain)
            .background(.orhadiBG)
            .environment(\.defaultMinListRowHeight, 20)
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Stop Studying", systemImage: "chevron.backward") {
                    viewModel.stopStudying()
                    dismiss()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.isRunning.toggle()
                } label: {
                    if viewModel.isRunning && !viewModel.studyFinished {
                        Label("Pause", systemImage: "pause")
                    } else {
                        Label("Play", systemImage: "play.fill")
                    }
                }
                .tint(.accentColor)
                .disabled(viewModel.studyFinished)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Next", systemImage: "forward.fill") {
                    viewModel.skipToNext()
                }
                .tint(.accentColor)
                .disabled(viewModel.studyFinished)
            }
        }
        .toolbarBackground(.orhadiBG, for: .navigationBar)
        .toolbarVisibility(.hidden, for: .tabBar)
        .disableIdleTimer()
        .onAppear {
            if !viewModel.isReady {
                viewModel.prepareSession(for: studies, with: settings.breakTime)
            }
        }
    }
}
