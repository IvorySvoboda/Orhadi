//
//  TasksView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 26/03/25.
//

import SwiftData
import SwiftUI

struct ToDosView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(Settings.self) private var settings

    @Query(sort: [.init(\ToDo.dueDate, order: .forward)], animation: .bouncy)
    private var todos: [ToDo]

    @State private var isAdding: Bool = false

    var body: some View {
        NavigationStack {
            List {
                if !todos.filter({ $0.dueDate > Date() && !$0.isCompleted }).isEmpty {
                    Section {
                        ForEach(todos.filter { $0.dueDate > Date() && !$0.isCompleted })
                        { todo in
                            ToDosListCell(todo: todo)
                        }
                    } header: {
                        SectionHeader(text: String(localized: "A Fazer"))
                    }.listRowBackground(OrhadiTheme.getBGColor(for: colorScheme))
                }

                if !todos.filter({$0.dueDate < Date() || $0.isCompleted}).isEmpty {
                    Section {
                        ForEach(
                            todos.sorted(by: { $0.dueDate > $1.dueDate }).filter {
                                $0.dueDate < Date() || $0.isCompleted
                            }
                        ) { todo in
                            ToDosListCell(todo: todo)
                        }
                    } header: {
                        SectionHeader(text: String(localized: "Completados ou Vencidos"))
                    }.listRowBackground(OrhadiTheme.getBGColor(for: colorScheme))
                }
            }
            .listStyle(PlainListStyle())
            .background(OrhadiTheme.getBGColor(for: colorScheme))
            .navigationTitle("Tarefas")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { isAdding = true }) {
                        Image(systemName: "plus.circle.fill").font(.title2)
                    }
                }
            }
            .toolbarBackground(
                OrhadiTheme.getBGColor(for: colorScheme),
                for: .navigationBar)
        }
        .sheet(
            isPresented: $isAdding,
            onDismiss: { isAdding = false },
            content: {
                ToDoAddView().interactiveDismissDisabled()
            })
    }
}

#Preview("ToDoView") {
    ToDosView()
        .modelContainer(SampleData.shared.container)
        .environment(Settings())
}
