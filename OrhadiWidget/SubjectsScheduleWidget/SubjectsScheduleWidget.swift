//
//  SubjectsScheduleWidget.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 07/07/25.
//

import WidgetKit
import SwiftUI
import SwiftData

struct SubjectsScheduleWidget: Widget {
    let kind: String = "SubjectsScheduleWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SubjectsScheduleWidgetEntryView(entry: entry)
                .containerBackground(.background, for: .widget)
                .modelContainer(DataManager.shared.container)
        }
        .configurationDisplayName("Class Schedule")
        .description("See today’s subjects without opening the app.")
    }
}

struct SubjectsScheduleWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily

    var entry: Provider.Entry
    let dataManager = DataManager.shared

    @Query(filter: #Predicate<Subject> { !$0.isSubjectDeleted }, sort: \.startTime)
    private var subjects: [Subject]

    var filteredSubjects: [Subject] {
        return subjects.filter {
            let todayEndTime = Calendar.current.date(
                bySettingHour: Calendar.current.component(.hour, from: $0.endTime),
                minute: Calendar.current.component(.minute, from: $0.endTime),
                second: 0,
                of: Date()
            )

            return Calendar.current.component(.weekday, from: $0.schedule)
                == Calendar.current.component(.weekday, from: .now)
                && todayEndTime ?? .distantFuture > .now
        }
    }

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            VStack {
                if filteredSubjects.isEmpty {
                    EmptyViewText()
                } else {
                    ForEach(filteredSubjects.prefix(3)) { subject in
                        SubjectScheduleWidgetRow(subject: subject)

                        if subject != filteredSubjects.prefix(3).last {
                            Divider()
                        }
                    }
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        case .systemMedium:
            HStack(spacing: 15) {
                let leftSide = filteredSubjects.prefix(3)
                let rightSide = filteredSubjects.prefix(6).filter {
                    !leftSide.contains($0)
                }

                if leftSide.isEmpty {
                    EmptyViewText()
                } else {
                    VStack {
                        ForEach(leftSide) { subject in
                            SubjectScheduleWidgetRow(subject: subject)

                            if subject != leftSide.last {
                                Divider()
                            }
                        }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                    Divider()

                    VStack {
                        ForEach(rightSide) { subject in
                            SubjectScheduleWidgetRow(subject: subject)

                            if subject != rightSide.last {
                                Divider()
                            }
                        }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
            }
        default:
            HStack(spacing: 15) {
                let leftSide = filteredSubjects.prefix(7)
                let rightSide = filteredSubjects.prefix(14).filter {
                    !leftSide.contains($0)
                }

                if leftSide.isEmpty {
                    EmptyViewText()
                } else {
                    VStack {
                        ForEach(leftSide) { subject in
                            SubjectScheduleWidgetRow(subject: subject)

                            if subject != leftSide.last {
                                Divider()
                            }
                        }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                    Divider()

                    VStack {
                        ForEach(rightSide) { subject in
                            SubjectScheduleWidgetRow(subject: subject)

                            if subject != rightSide.last {
                                Divider()
                            }
                        }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
            }
        }
    }
}

struct SubjectScheduleWidgetRow: View {
    var subject: Subject

    @Query private var settings: [Settings]

    var body: some View {
        HStack(spacing: 5) {

            if subject.isOngoing && settings.first?.showCurrentSubjectIndicator ?? true {
                RoundedRectangle(cornerRadius: 3, style: .circular)
                    .fill(Color.cyan)
                    .frame(width: 5)
                    .frame(maxHeight: 40)
            }

            VStack(alignment: .leading) {
                if !subject.isRecess {
                    Text(subject.name.nilIfEmpty() ?? String(localized: "No Name"))
                        .font(.headline)
                        .fontWeight(.semibold)
                } else {
                    Text("Interval")
                        .textCase(.uppercase)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 10, alignment: .center)
                    Text("\(subject.startTime.formatToHour()) – \(subject.endTime.formatToHour())")
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
        }.frame(maxWidth: .infinity, alignment: .topLeading)
    }
}
