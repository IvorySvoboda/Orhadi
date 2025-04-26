//
//  TasksView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 26/03/25.
//

import SwiftData
import SwiftUI
import MarkdownUI

struct ToDosView: View {
    @Environment(Settings.self) private var settings
    @Query(sort: \ToDo.dueDate, animation: .smooth) private var todos: [ToDo]

    @State private var viewModel = ToDosViewModel()

    var body: some View {
        NavigationStack {
            List {
                if viewModel.showPendingSection {
                    Section(header: SectionHeader(text: String(localized: "Em Atraso"))) {
                        ForEach(viewModel.pendingTodos) { todo in
                            ToDoRow(todo: todo, todoToEdit: $viewModel.todoToEdit)
                        }
                    }
                    .listRowBackground(Color.orhadiBG)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .animation(.smooth, value: viewModel.pendingTodos)
                }

                if viewModel.showUpcomingSection {
                    Section(header: SectionHeader(text: String(localized: "A Fazer"))) {
                        ForEach(viewModel.upcomingTodos) { todo in
                            ToDoRow(todo: todo, todoToEdit: $viewModel.todoToEdit)
                        }
                    }
                    .listRowBackground(Color.orhadiBG)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .animation(.smooth, value: viewModel.upcomingTodos)
                }

                if viewModel.showCompletedSection {
                    Section(header: SectionHeader(text: String(localized: "Completadas ou Vencidas"))) {
                        ForEach(viewModel.completedOrExpiredTodos) { todo in
                            ToDoRow(todo: todo, todoToEdit: $viewModel.todoToEdit)
                        }
                    }
                    .listRowBackground(Color.orhadiBG)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .animation(.smooth, value: viewModel.completedOrExpiredTodos)
                }
            }
            .orhadiPlainListStyle()
            .navigationTitle("Tarefas")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.addNewTodo()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .overlay { overlay }
            .sheet(item: $viewModel.todoToAdd) { todo in
                ToDoSheetView(todo: todo, isNew: true)
                    .interactiveDismissDisabled()
            }
            .sheet(item: $viewModel.todoToEdit) { todo in
                ToDoSheetView(todo: todo, isNew: false)
                    .interactiveDismissDisabled()
            }
            .onAppear {
                viewModel.updateTodos(todos, gracePeriod: settings.gracePeriod)
            }
            .onChange(of: todos) { _, newTodos in
                viewModel.updateTodos(newTodos, gracePeriod: settings.gracePeriod)
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
                        viewModel.addNewTodo()
                    }
                    .buttonStyle(.borderedProminent)
                    .foregroundStyle(Color.orhadiBG)
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
