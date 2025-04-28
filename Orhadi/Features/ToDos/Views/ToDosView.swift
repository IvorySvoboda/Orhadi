//
//  TasksView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 26/03/25.
//

import SwiftData
import SwiftUI

struct ToDosView: View {
    @Environment(\.modelContext) private var context
    @Environment(Settings.self) private var settings

    @Query(
        sort: [.init(\ToDo.dueDate, order: .forward)],
        animation: .smooth
    ) private var todos: [ToDo]

    @State private var viewModel = ToDosViewModel()

    var body: some View {
        NavigationStack {
            List {
                if viewModel.showOverdueSection {
                    Section(
                        header: SectionHeader(
                            text: String(localized: "Em Atraso")
                        )
                    ) {
                        ForEach(viewModel.overdueTodos, id: \.id) { todo in
                            ToDoRow(
                                todo: todo,
                                todoToEdit: $viewModel.todoToEdit,
                                deleteToDo: {
                                    viewModel.deleteTodo(todo, using: context)
                                }
                            )
                        }
                    }
                    .listRowBackground(Color.orhadiBG)
                    .transition(.opacity.combined(with: .slide))
                    .animation(.smooth, value: viewModel.overdueTodos)
                }

                if viewModel.showPendingSection {
                    Section(
                        header: SectionHeader(
                            text: String(localized: "A Fazer")
                        )
                    ) {
                        ForEach(viewModel.pendingTodos, id: \.id) { todo in
                            ToDoRow(
                                todo: todo,
                                todoToEdit: $viewModel.todoToEdit,
                                deleteToDo: {
                                    viewModel.deleteTodo(todo, using: context)
                                }
                            )
                        }
                    }
                    .listRowBackground(Color.orhadiBG)
                    .transition(.opacity.combined(with: .slide))
                    .animation(.smooth, value: viewModel.pendingTodos)
                }

                if viewModel.showCompletedSection {
                    Section(
                        header: SectionHeader(
                            text: String(localized: "Completadas")
                        )
                    ) {
                        ForEach(viewModel.completedTodos, id: \.id) { todo in
                            ToDoRow(
                                todo: todo,
                                todoToEdit: $viewModel.todoToEdit,
                                deleteToDo: {
                                    viewModel.deleteTodo(todo, using: context)
                                }
                            )
                        }
                    }
                    .listRowBackground(Color.orhadiBG)
                    .transition(.push(from: .trailing))
                    .animation(.smooth, value: viewModel.completedTodos)
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
        }
        .onChange(of: todos) { _, _ in
            viewModel.updateTodos(todos)
        }
        .onChange(of: viewModel.pendingTodos) { _, _ in
            viewModel.updateSectionVisibility()
        }
        .onChange(of: viewModel.overdueTodos) { _, _ in
            viewModel.updateSectionVisibility()
        }
        .onChange(of: viewModel.completedTodos) { _, _ in
            viewModel.updateSectionVisibility()
        }
        .onChange(of: viewModel.todoToEdit) { _, _ in
            viewModel.updateSectionVisibility()
        }
        .onAppear {
            NotificationCenter.default.addObserver(
                forName: UIApplication.didBecomeActiveNotification,
                object: nil,
                queue: .main
            ) { _ in
                viewModel.updateTodos(todos)
            }

            viewModel.startUpdatingTodos()

            viewModel.updateTodos(todos)
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(
                self,
                name: UIApplication.didBecomeActiveNotification,
                object: nil
            )
            viewModel.stopUpdatingTodos()
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
