//
//  StudyingView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 05/04/25.
//

import SwiftUI
import SwiftData

struct StudyingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Settings.self) private var settings
    @State private var vm: ViewModel

    // MARK: - Views

    var body: some View {
        VStack {
            Divider()

            HStack {
                if vm.currentSessionIndex < vm.sessionItems.count {
                    Text(vm.currentStudyName)
                        .titleStyle()
                } else {
                    Text("All studies completed! 🔥")
                        .titleStyle()
                }
                Spacer()
            }
            .padding(.horizontal)
            .offset(y: 2)

            Divider()

            VStack {
                HStack {
                    RollingTextView(text: vm.timeString)
                        .font(.system(size: 40, weight: .bold, design: .monospaced))
                }
            }.frame(height: 200)

            List {
                if vm.currentSessionIndex < vm.sessionItems.count {
                    ForEach(vm.filteredSessionItems) { sessionItem in
                        if sessionItem.isBreak {
                            HStack {
                                Text("Interval")
                                Spacer()
                                Text(vm.breakTime.durationString())
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
            .environment(\.defaultMinListRowHeight, 20)
        }
        .navigationBarBackButtonHidden()
        .toolbar { toolbarComponents }
        .toolbarVisibility(.hidden, for: .tabBar)
        .onChange(of: vm.isRunning) { _, _ in
            vm.handleRunningChange()
        }
        .disableIdleTimer()
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarComponents: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Stop Studying", systemImage: "chevron.backward") {
                vm.stopStudying()
                dismiss()
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                vm.isRunning.toggle()
            } label: {
                if vm.isRunning && !vm.studyFinished {
                    Label("Pause", systemImage: "pause")
                } else {
                    Label("Play", systemImage: "play.fill")
                }
            }
            .tint(.accentColor)
            .disabled(vm.studyFinished)
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button("Next", systemImage: "forward.fill") {
                vm.skipToNext()
            }
            .tint(.accentColor)
            .disabled(vm.studyFinished)
        }
    }

    // MARK: - INIT

    init(studies: [SRStudy]) {
        _vm = State(initialValue: ViewModel(studies: studies, dataManager: .shared))
    }
}
