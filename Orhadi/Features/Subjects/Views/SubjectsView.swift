//
//  Subjects.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 26/03/25.
//

import SwiftData
import SwiftUI
import WidgetKit

struct SubjectsView: View {
    @Environment(Settings.self) private var settings

    @Query(filter: #Predicate<Subject> {
        !$0.isSubjectDeleted
    }, sort: \Subject.startTime, animation: .smooth) private var subjects: [Subject]

    // MARK: - Properties

    @State private var selectedDay: Int = Calendar.current.component(.weekday, from: Date())
    @State private var showConfirmation: Bool = false
    @State private var subjectToAdd: Subject?
    @State private var subjectToEdit: Subject?
    @State private var showTitle: Bool = false
    @State private var showSelectedWeekday: Bool = false
    @State private var hideOverlay: Bool = false

    // MARK: - Computed Properties

    var isTodayEmpty: Bool {
        subjects.filter {
            Calendar.current.component(.weekday, from: $0.schedule) == selectedDay
        }.isEmpty
    }

    var toolbarTitle: String {
        Calendar.current.weekdaySymbols[selectedDay - 1].uppercased()
    }

    // MARK: - Views

    var body: some View {
        NavigationStack {
            List {
                WeekdayPickerBar(selectedDay: $selectedDay)
                    .opacity(showSelectedWeekday ? 0 : 1)

                ForEach(subjects.filter {
                    Calendar.current.component(.weekday, from: $0.schedule) == selectedDay
                }) { subject in
                    SubjectRow(
                        subject: subject,
                        onAdd: { subjectToAdd = subject },
                        onEdit: { subjectToEdit = subject }
                    )
                }
            }
            .listStyle(.plain)
            .navigationTitle("Subjects")
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
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ZStack {
                        Text("Subjects")
                            .font(.headline)
                            .frame(height: 30)
                            .opacity(showTitle ? 1 : 0)
                            .blur(radius: showTitle ? 0 : 3)
                            .offset(y: showSelectedWeekday ? -8 : showTitle ? 0 : 14)

                        Text(toolbarTitle)
                            .foregroundStyle(.tint)
                            .font(.caption)
                            .frame(height: 30)
                            .opacity(showSelectedWeekday ? 1 : 0)
                            .blur(radius: showSelectedWeekday ? 0 : 3)
                            .offset(y: showSelectedWeekday ? 8 : 14)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showConfirmation.toggle()
                    } label: {
                        if #available(iOS 26, *) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundStyle(Color.accentColor)
                        } else {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                    }
                }
            }
            .overlay {
                if isTodayEmpty, !hideOverlay {
                    ContentUnavailableView {
                        Label("No Subjects", systemImage: "book")
                    } description: {
                        Text("No subjects today. How about taking some time to rest a little?")
                    }
                }
            }
            .sheet(item: $subjectToAdd) { subject in
                SubjectSheetView(subject: subject, isNew: true)
                    .interactiveDismissDisabled()
            }
            .sheet(item: $subjectToEdit) { subject in
                SubjectSheetView(subject: subject, isNew: false)
                    .interactiveDismissDisabled()
            }
            .sheet(isPresented: $showConfirmation) {
                VStack {
                    VStack(spacing: 10) {
                        ForEach([
                            (title: String(localized: "Add Subejct"), isRecess: false),
                            (title: String(localized: "Add Interval"), isRecess: true)
                        ], id: \.title) { option in
                            Button {
                                showConfirmation.toggle()
                                subjectToAdd = Subject(
                                    schedule: Calendar.current.date(bySetting: .weekday, value: selectedDay, of: Date(timeIntervalSince1970: 0))!,
                                    isRecess: option.isRecess)
                            } label: {
                                if #available(iOS 26, *) {
                                    Capsule()
                                        .fill(Color.accentColor)
                                        .frame(maxWidth: .infinity, minHeight: 45)
                                        .overlay {
                                            Text(option.title.uppercased())
                                                .font(.headline)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(Color.orhadiSecondaryForeground)
                                        }
                                } else {
                                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                                        .fill(Color.accentColor)
                                        .frame(maxWidth: .infinity, minHeight: 45)
                                        .overlay {
                                            Text(option.title.uppercased())
                                                .font(.headline)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(Color.orhadiSecondaryForeground)
                                        }
                                }
                            }
                        }
                    }
                    .offset(y: 15)
                }
                .padding()
                .presentationDetents([.height(135)])
                .presentationDragIndicator(.visible)
            }
            .onChange(of: subjects) { _, _ in
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
}
