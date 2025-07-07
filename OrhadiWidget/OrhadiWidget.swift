//
//  OrhadiWidget.swift
//  OrhadiWidget
//
//  Created by Zyvoxi . on 05/07/25.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let entry = SimpleEntry(date: .now)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 1, to: .now)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

// MARK: - Subjects Widget

struct OrhadiSubjectsWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily

    var entry: Provider.Entry

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
                    Text("Parece que não tem mais nada por aqui. Que tal aproveitar pra estudar um pouco?")
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    ForEach(filteredSubjects.prefix(3)) { subject in
                        SubjectWidgetRow(subject: subject)

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
                    Text("Parece que não tem mais nada por aqui. Que tal aproveitar pra estudar um pouco?")
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    VStack {
                        ForEach(leftSide) { subject in
                            SubjectWidgetRow(subject: subject)

                            if subject != leftSide.last {
                                Divider()
                            }
                        }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                    Divider()

                    VStack {
                        ForEach(rightSide) { subject in
                            SubjectWidgetRow(subject: subject)

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
                    Text("Parece que não tem mais nada por aqui. Que tal aproveitar pra estudar um pouco?")
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    VStack {
                        ForEach(leftSide) { subject in
                            SubjectWidgetRow(subject: subject)

                            if subject != leftSide.last {
                                Divider()
                            }
                        }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                    Divider()

                    VStack {
                        ForEach(rightSide) { subject in
                            SubjectWidgetRow(subject: subject)

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

struct SubjectWidgetRow: View {
    var subject: Subject

    @Query private var settings: [Settings]

    var body: some View {
        HStack(spacing: 5) {

            if subject.isOngoing && settings.first?.showCurrentSubjectIndicator ?? Settings().showCurrentSubjectIndicator {
                RoundedRectangle(cornerRadius: 3, style: .circular)
                    .fill(Color.cyan)
                    .frame(width: 5)
                    .frame(maxHeight: .infinity)
            }

            VStack(alignment: .leading) {
                if !subject.isRecess {
                    Text("\(subject.name)")
                        .font(.headline)
                        .fontWeight(.semibold)
                } else {
                    Text("Intervalo".uppercased())
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

struct OrhadiSubjectsWidget: Widget {
    let kind: String = "OrhadiSubjectsScheduleWidget"

    var container: ModelContainer {
        do {
            return try createContainer()
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            OrhadiSubjectsWidgetEntryView(entry: entry)
                .containerBackground(.background, for: .widget)
                .modelContainer(container)
        }
        .configurationDisplayName("Agenda de Aulas")
        .description("Visualize as matérias do dia sem abrir o app.")
    }
}

// MARK: - ToDos Widget

struct OrhadiTodosWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily

    var entry: Provider.Entry

    @Query(filter: #Predicate<ToDo> { !$0.isToDoDeleted && !$0.isArchived }, sort: \.dueDate)
    private var todos: [ToDo]

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            VStack {
                if todos.filter({ !$0.isCompleted }).isEmpty {
                    Text("Parece que não tem mais nada por aqui. Que tal aproveitar pra estudar um pouco?")
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    ForEach(todos.filter({ !$0.isCompleted }).prefix(3)) { todo in
                        TodoWidgetRow(todo: todo)

                        if todo != todos.filter({ !$0.isCompleted }).prefix(3).last {
                            Divider()
                        }
                    }
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        case .systemMedium:
            VStack {
                if todos.filter({ !$0.isCompleted }).isEmpty {
                    Text("Parece que não tem mais nada por aqui. Que tal aproveitar pra estudar um pouco?")
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    ForEach(todos.filter({ !$0.isCompleted }).prefix(3)) { todo in
                        TodoWidgetRow(todo: todo)

                        if todo != todos.filter({ !$0.isCompleted }).prefix(3).last {
                            Divider()
                        }
                    }
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        default:
            VStack {
                if todos.filter({ !$0.isCompleted }).isEmpty {
                    Text("Parece que não tem mais nada por aqui. Que tal aproveitar pra estudar um pouco?")
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    ForEach(todos.filter({ !$0.isCompleted }).prefix(7)) { todo in
                        TodoWidgetRow(todo: todo)

                        if todo != todos.filter({ !$0.isCompleted }).prefix(7).last {
                            Divider()
                        }
                    }
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

struct TodoWidgetRow: View {
    var todo: ToDo

    var body: some View {
        HStack {
            if !todo.isCompleted, todo.dueDate < .now {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
            }

            VStack(alignment: .leading) {
                HStack {
                    if todo.priority.rawValue > 0 {
                        Image(systemName: "exclamationmark\(todo.priority.rawValue > 1 ? ".\(todo.priority.rawValue)" : "")")
                            .font(.subheadline)
                            .foregroundStyle(todo.isCompleted ? Color.secondary : Color.orange)
                            .frame(width: 5, alignment: .center)
                            .padding(.leading, 2.5)
                    }

                    Text(todo.title.nilIfEmpty() ?? String(localized: "Não Informado"))
                        .font(.headline)
                        .fontWeight(.semibold)
                }.frame(maxWidth: .infinity, alignment: .leading)

                HStack {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 10, alignment: .center)
                    Text("\(todo.formattedDueDate)")
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
        }.frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

struct OrhadiTodosWidget: Widget {
    let kind: String = "OrhadiPendingTodosWidget"

    var container: ModelContainer {
        do {
            return try createContainer()
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            OrhadiTodosWidgetEntryView(entry: entry)
                .containerBackground(.background, for: .widget)
                .modelContainer(container)
        }
        .configurationDisplayName("Tarefas Pendentes")
        .description("Visualize as tarefas que faltam completar sem abrir o app.")
    }
}
