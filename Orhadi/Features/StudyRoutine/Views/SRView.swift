//
//  SRView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 31/03/25.
//

import SwiftData
import SwiftUI

struct SRView: View {
    @Environment(Settings.self) private var settings

    @Query(filter: #Predicate<SRStudy> {
        !$0.isStudyDeleted
    }, sort: \SRStudy.name, animation: .smooth) private var studies: [SRStudy]

    // MARK: - Properties

    @State private var studyToAdd: SRStudy? = nil
    @State private var studyToEdit: SRStudy? = nil
    @State private var studiesToStudy: [SRStudy] = []
    @State private var navigateToStudyingView: Bool = false
    @State private var selectedDay: Int = Calendar.current.component(.weekday, from: Date())
    @State private var scrollOffsetY: Int = 151

    // MARK: - Computed Properties

    var isTodayEmpty: Bool {
        studies.filter {
            Calendar.current.component(.weekday, from: $0.studyDay) == selectedDay
        }.isEmpty
    }

    var toolbarTitle: String {
        Calendar.current.weekdaySymbols[selectedDay - 1].uppercased()
    }

    var studiesForToday: [SRStudy] {
        studies.filter { $0.isForToday && !$0.hasStudiedThisWeek }
    }

    var canStartStudying: Bool {
        !studiesForToday.isEmpty
    }

    // MARK: - Views

    var body: some View {
        NavigationStack {
            List {
                weekdayPickerBar

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
            .orhadiPlainListStyle()
            .navigationTitle("Rotina de Estudos")
            .overlay { overlay }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ZStack {
                        Text("Rotina de Estudos")
                            .font(.headline)
                            .opacity(scrollOffsetY < 115 ? 1 : 0)
                            .offset(y: scrollOffsetY <= 60 ? -8 : 0)

                        Text(toolbarTitle)
                            .foregroundStyle(.tint)
                            .font(.caption)
                            .opacity(scrollOffsetY <= 60 ? 1 : 0)
                            .offset(y: scrollOffsetY <= 60 ? 8 : 14)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        studyToAdd = SRStudy()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.accentColor)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if canStartStudying {
                            studiesToStudy = studiesForToday
                            navigateToStudyingView = true
                        }
                    } label: {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                    }
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

    private var weekdayPickerBar: some View {
        WeekdayPickerBar(selectedDay: $selectedDay)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onChange(of: geo.frame(in: .global).minY) { _, newY in
                            withAnimation(.smooth(duration: 0.25)) {
                                scrollOffsetY = Int(newY)
                            }
                        }
                }
            )
    }

    private var overlay: some View {
        Group {
            if isTodayEmpty && scrollOffsetY < 300 {
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
