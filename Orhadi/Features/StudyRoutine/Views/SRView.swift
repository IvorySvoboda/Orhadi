//
//  SRView.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 31/03/25.
//

import SwiftData
import SwiftUI

struct SRView: View {
    @Environment(Settings.self) private var settings

    @Query(filter: #Predicate<SRStudy> {
        !$0.isStudyDeleted
    }, sort: \SRStudy.name, animation: .smooth) private var studies: [SRStudy]

    // MARK: - Properties

    @State private var studyToAdd: SRStudy?
    @State private var studyToEdit: SRStudy?
    @State private var studiesToStudy: [SRStudy] = []
    @State private var navigateToStudyingView: Bool = false
    @State private var selectedDay: Int = Calendar.current.component(.weekday, from: Date())
    @State private var showTitle: Bool = false
    @State private var showSelectedWeekday: Bool = false
    @State private var hideOverlay: Bool = false

    // MARK: - Computed Properties

    var isTodayEmpty: Bool {
        studies.filter {
            Calendar.current.component(.weekday, from: $0.studyDay) == selectedDay
        }.isEmpty
    }

    var toolbarTitle: String {
        Calendar.current.weekdaySymbols[selectedDay - 1].uppercased()
    }

    var studiesForTheSelectedDay: [SRStudy] {
        studies.filter { Calendar.current.component(.weekday, from: $0.studyDay) == selectedDay && !$0.hasStudiedThisWeek }
    }

    var canStartStudying: Bool {
        !studiesForTheSelectedDay.isEmpty
    }

    // MARK: - Views

    var body: some View {
        NavigationStack {
            List {
                WeekdayPickerBar(selectedDay: $selectedDay)
                    .opacity(showSelectedWeekday ? 0 : 1)

                ForEach(studies.filter {
                    Calendar.current.component(.weekday, from: $0.studyDay) == selectedDay
                }) { study in
                    SRRow(
                        study: study,
                        onStudy: {
                            studiesToStudy = [study]
                            navigateToStudyingView.toggle()
                        },
                        onAdd: { studyToAdd = study },
                        onEdit: { studyToEdit = study }
                    )
                }
            }
            .listStyle(.plain)
            .navigationTitle("Study Routine")
            .onScrollGeometryChange(for: CGFloat.self, of: { geo in
                geo.contentOffset.y
            }, action: { _, scrollOffset in
                debugPrint(scrollOffset)

                let shouldShowTitle = scrollOffset >= -101
                if shouldShowTitle != showTitle {
                    withAnimation(.smooth(duration: 0.5)) {
                        showTitle = shouldShowTitle
                    }
                }

                let shouldShowWeekday = scrollOffset >= -56
                if shouldShowWeekday != showSelectedWeekday {
                    withAnimation(.smooth(duration: 0.5)) {
                        showSelectedWeekday = shouldShowWeekday
                    }
                }

                let shouldHideOverlay = scrollOffset < -300
                if shouldHideOverlay != hideOverlay {
                    withAnimation(.smooth(duration: 0.5)) {
                        hideOverlay = shouldHideOverlay
                    }
                }
            })
            .overlay { overlay }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ZStack {
                        Text("Study Routine")
                            .font(.headline)
                            .frame(height: 30)
                            .opacity(showTitle ? 1 : 0)
                            .blur(radius: showTitle ? 0 : 3)
                            .offset(y: showSelectedWeekday ? -8 : showTitle ? 0 : 14)

                        Text(toolbarTitle)
                            .foregroundStyle(.tint)
                            .font(.caption)
                            .frame(height: 30)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .opacity(showSelectedWeekday ? 1 : 0)
                            .blur(radius: showSelectedWeekday ? 0 : 3)
                            .offset(y: showSelectedWeekday ? 8 : 14)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        studyToAdd = SRStudy(studyDay: Calendar.current.date(bySetting: .weekday, value: selectedDay, of: Date(timeIntervalSince1970: 0))!)
                    } label: {
                        Label("Add", systemImage: "plus")
                    }.tint(.accentColor)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if canStartStudying {
                            studiesToStudy = studiesForTheSelectedDay
                            navigateToStudyingView = true
                        }
                    } label: {
                        Label("Start Studying", systemImage: "play.fill")
                    }
                    .tint(.accentColor)
                    .disabled(!canStartStudying)
                }
            }
            .navigationDestination(isPresented: $navigateToStudyingView) {
                StudyingView(studies: $studiesToStudy)
            }
            .sheet(item: $studyToAdd) { study in
                SRSheetView(study: study, isNew: true)
                    .interactiveDismissDisabled()
            }
            .sheet(item: $studyToEdit) { study in
                SRSheetView(study: study, isNew: false)
                    .interactiveDismissDisabled()
            }
        }
    }

    private var overlay: some View {
        Group {
            if isTodayEmpty, !hideOverlay {
                ContentUnavailableView {
                    Label("Nothing to Study", systemImage: "graduationcap")
                } description: {
                    Text("Nothing to study today. How about taking a little time to rest?")
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
