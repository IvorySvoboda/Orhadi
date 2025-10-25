//
//  PendingTodosWidget.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 07/07/25.
//

import WidgetKit
import SwiftUI
import SwiftData

struct PendingTodosWidget: Widget {
    let kind: String = "PendingTodosWidget"

    var container = createContainer()

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PendingTodosWidgetEntryView(entry: entry)
                .containerBackground(.background, for: .widget)
                .modelContainer(container)
        }
        .configurationDisplayName("Pending To-Dos")
        .description("See your incomplete to-dos without opening the app.")
    }
}

struct PendingTodosWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily

    var entry: Provider.Entry

    @Query(filter: #Predicate<ToDo> { !$0.isToDoDeleted && !$0.isArchived }, sort: \.dueDate)
    private var todos: [ToDo]

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            VStack {
                if todos.filter({ !$0.isCompleted }).isEmpty {
                    EmptyViewText()
                } else {
                    ForEach(todos.filter({ !$0.isCompleted }).prefix(3)) { todo in
                        PendingTodoWidgetRow(todo: todo)

                        if todo != todos.filter({ !$0.isCompleted }).prefix(3).last {
                            Divider()
                        }
                    }
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        case .systemMedium:
            VStack {
                if todos.filter({ !$0.isCompleted }).isEmpty {
                    EmptyViewText()
                } else {
                    ForEach(todos.filter({ !$0.isCompleted }).prefix(3)) { todo in
                        PendingTodoWidgetRow(todo: todo)

                        if todo != todos.filter({ !$0.isCompleted }).prefix(3).last {
                            Divider()
                        }
                    }
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        default:
            VStack {
                if todos.filter({ !$0.isCompleted }).isEmpty {
                    EmptyViewText()
                } else {
                    ForEach(todos.filter({ !$0.isCompleted }).prefix(7)) { todo in
                        PendingTodoWidgetRow(todo: todo)

                        if todo != todos.filter({ !$0.isCompleted }).prefix(7).last {
                            Divider()
                        }
                    }
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

struct PendingTodoWidgetRow: View {
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

                    Text(todo.title.nilIfEmpty() ?? String(localized: "Not provided"))
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
