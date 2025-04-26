//
//  SRView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 31/03/25.
//

import SwiftData
import SwiftUI

struct SRView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(Settings.self) private var settings

    @Query(sort: \SRStudy.name, animation: .smooth)
    private var studies: [SRStudy]

    @State private var viewModel = SRViewModel()

    var body: some View {
        NavigationStack {
            List {
                WeekdayPickerBar(selectedDay: $viewModel.selectedDay)
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .onChange(of: geo.frame(in: .global).minY) { _, newY in
                                    viewModel.updateScrollOffset(with: newY)
                                }
                        }
                    )

                ForEach(viewModel.filteredStudies) { study in
                    SRRow(
                        study: study,
                        studiesToStudy: $viewModel.studiesToStudy,
                        navigateToStudyingView: $viewModel.navigateToStudyingView,
                        studyToAdd: $viewModel.studyToAdd,
                        studyToEdit: $viewModel.studyToEdit
                    )
                }
            }
            .orhadiPlainListStyle()
            .navigationTitle("Rotina de Estudos")
            .overlay { overlay }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ZStack {
                        Text("Rotina de Estudos")
                            .font(.headline)
                            .opacity(viewModel.scrollOffsetY < 115 ? 1 : 0)
                            .offset(y: viewModel.scrollOffsetY <= 70 ? -8 : 0)

                        Text(viewModel.toolbarTitle)
                            .foregroundStyle(.tint)
                            .font(.caption)
                            .opacity(viewModel.scrollOffsetY <= 70 ? 1 : 0)
                            .offset(y: viewModel.scrollOffsetY <= 70 ? 8 : 14)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.addNewStudy()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.accentColor)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if viewModel.canStartStudying {
                            viewModel.prepareStudiesToStudy()
                        }
                    } label: {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                    }
                    .disabled(!viewModel.canStartStudying)
                }
            }
            .navigationDestination(isPresented: $viewModel.navigateToStudyingView) {
                StudyingView(studies: $viewModel.studiesToStudy)
            }
            .sheet(item: $viewModel.studyToAdd) { study in
                SRSheetView(study: study, isNew: true)
                    .interactiveDismissDisabled()
            }
            .sheet(item: $viewModel.studyToEdit) { study in
                SRSheetView(study: study, isNew: false)
                    .interactiveDismissDisabled()
            }
            .onAppear {
                viewModel.updateStudies(studies)
            }
            .onChange(of: studies) { _, newStudies in
                viewModel.updateStudies(newStudies)
            }
        }
    }

    private var overlay: some View {
        Group {
            if viewModel.isTodayEmpty && viewModel.scrollOffsetY < 300 {
                ContentUnavailableView {
                    Label("Nenhuma Matéria", systemImage: "graduationcap")
                } description: {
                    Text("Nenhuma matéria hoje. Que tal aproveitar pra descansar um pouco?")
                }
            }
        }
    }
}

#Preview("SharedStudyRoutineView") {
    SRView()
        .modelContainer(SampleData.shared.container)
        .environment(Settings())
}
