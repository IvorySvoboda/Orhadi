//
//  SRView.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 31/03/25.
//

import SwiftData
import SwiftUI

struct SRView: View {
    @Environment(Settings.self) private var settings
    @State private var viewModel = ViewModel(dataManager: .shared)

    // MARK: - Views

    var body: some View {
        NavigationStack {
            List {
                WeekdayPickerBar(selectedDay: $viewModel.selectedDay)
                    .opacity(viewModel.showSelectedWeekday ? 0 : 1)

                ForEach(viewModel.filteredStudies) { study in
                    SRRowView(
                        study: study,
                        onStudy: {
                            viewModel.studiesToStudy = [study]
                            viewModel.navigateToStudyingView.toggle()
                        },
                        onAdd: { viewModel.studyToAdd = study },
                        onEdit: { viewModel.studyToEdit = study },
                        onDelete: { try? viewModel.softDeleteStudy(study) }
                    )
                }
            }
            .listStyle(.plain)
            .navigationTitle("Study Routine")
            .onScrollGeometryChange(for: CGFloat.self, of: { geo in
                geo.contentOffset.y
            }, action: { _, scrollOffset in
                viewModel.handleScrollGeoChange(scrollOffset)
            })
            .overlay {
                if viewModel.filteredStudies.isEmpty, !viewModel.hideOverlay {
                    ContentUnavailableView {
                        Label("Nothing to Study", systemImage: "graduationcap")
                    } description: {
                        Text("Nothing to study today. How about taking a little time to rest?")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ZStack {
                        Text("Study Routine")
                            .font(.headline)
                            .frame(height: 30)
                            .opacity(viewModel.showTitle ? 1 : 0)
                            .blur(radius: viewModel.showTitle ? 0 : 3)
                            .offset(y: viewModel.showSelectedWeekday ? -8 : viewModel.showTitle ? 0 : 14)

                        Text(viewModel.toolbarTitle)
                            .foregroundStyle(.tint)
                            .font(.caption)
                            .frame(height: 30)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .opacity(viewModel.showSelectedWeekday ? 1 : 0)
                            .blur(radius: viewModel.showSelectedWeekday ? 0 : 3)
                            .offset(y: viewModel.showSelectedWeekday ? 8 : 14)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add", systemImage: "plus") {
                        viewModel.studyToAdd = SRStudy(studyDay: Calendar.current.date(
                            bySetting: .weekday,
                            value: viewModel.selectedDay,
                            of: Date(timeIntervalSince1970: 0))!)
                    }.tint(.accentColor)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Start Studying", systemImage: "play.fill") {
                        if viewModel.canStartStudying {
                            viewModel.studiesToStudy = viewModel.studiesForTheSelectedDay
                            viewModel.navigateToStudyingView = true
                        }
                    }
                    .tint(.accentColor)
                    .disabled(!viewModel.canStartStudying)
                }
            }
            .navigationDestination(isPresented: $viewModel.navigateToStudyingView) {
                StudyingView(studies: viewModel.studiesToStudy)
            }
            .sheet(item: $viewModel.studyToAdd) { study in
                SRSheetView(study: study, isNew: true)
                    .interactiveDismissDisabled()
            }
            .sheet(item: $viewModel.studyToEdit) { study in
                SRSheetView(study: study, isNew: false)
                    .interactiveDismissDisabled()
            }
        }
    }
}
