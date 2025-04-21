//
//  TasksView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 26/03/25.
//

import SwiftData
import SwiftUI

struct ToDosView: View {
    @Environment(OrhadiTheme.self) private var theme
    @Environment(Settings.self) private var settings

    @Query(sort: [.init(\ToDo.dueDate, order: .forward)], animation: .bouncy)
    private var todos: [ToDo]

    @State private var showAddSheet: Bool = false

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
                    }.listRowBackground(theme.bgColor())
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
                    }.listRowBackground(theme.bgColor())
                }
            }
            .modifier(DefaultPlainList())
            .navigationTitle("Tarefas")
            .overlay {
                overlay
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showAddSheet.toggle() }) {
                        Image(systemName: "plus.circle.fill").font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                ToDoAddView()
                    .interactiveDismissDisabled()
            }
        }
    }

    private var overlay: some View {
        Group {
            if todos.isEmpty {
                ContentUnavailableView {
                    Label("Sem Tarefas", systemImage: "list.bullet.clipboard")
                } description: {
                    Text("Adicione novas tarefas para começar a se organizar.")
                } actions: {
                    Button("Adicionar Tarefa") {
                        showAddSheet.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                    .foregroundStyle(theme.bgColor())
                }
            }
        }
    }
}

#Preview("ToDoView") {
    ToDosView()
        .modelContainer(SampleData.shared.container)
        .environment(Settings())
}
