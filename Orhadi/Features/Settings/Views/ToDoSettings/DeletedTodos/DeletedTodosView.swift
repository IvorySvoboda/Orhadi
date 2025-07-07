//
//  DeletedTodosView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 05/05/25.
//

import SwiftUI
import SwiftData
import WidgetKit

struct DeletedTodosView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode

    @Query(filter: #Predicate<ToDo> { $0.isToDoDeleted }, sort: \.deletedAt, animation: .smooth)
    private var deletedTodos: [ToDo]

    @State private var selectedTodos = Set<ToDo>()

    /// Delete Confirmation
    @State private var showDeleteAllConfirmation = false
    @State private var showDeleteSelectedConfirmation = false

    var canShowBottomBar: Bool {
        if #available(iOS 26, *) {
            return false
        } else {
            return true
        }
    }

    // MARK: - Views

    var body: some View {
        List(selection: $selectedTodos) {
            Section {} footer: {
                Text("As tarefas ficam disponíveis aqui por 30 dias. Após esse período, as tarefas serão apagadas definitivamente.")
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity)
            }

            Section {
                ForEach(deletedTodos) { todo in
                    DeletedTodosRowView(todo: todo)
                        .tag(todo)
                }
                .orhadiListRowBackground()
            }
        }
        .orhadiListStyle()
        .navigationTitle("Tarefas Apagadas")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.visible, for: .bottomBar)
        .toolbarBackground(Color.orhadiBG, for: .bottomBar)
        /// BottomBar é apenas para o iOS 18
        .toolbarVisibility(editMode?.wrappedValue.isEditing == true ? .visible : .hidden, for: .bottomBar)
        /// Oculta a TabBar no iOS 26+
        .toolbarVisibility(editMode?.wrappedValue.isEditing == true && !canShowBottomBar ? .hidden : .visible, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }

            ToolbarItemGroup(placement: .bottomBar) {
//                HStack {
                    Button(selectedTodos.isEmpty ? "Restaurar Todas" : "Restaurar") {
                        selectedTodos.isEmpty ? restoreAllTodos() : restoreSelectedTodos()
                    }

                    Spacer()

                    Button(selectedTodos.isEmpty ? "Apagar Tudo" : "Apagar") {
                        selectedTodos.isEmpty ? showDeleteAllConfirmation.toggle() : showDeleteSelectedConfirmation.toggle()
                    }
                    .confirmationDialog(
                        "\(deletedTodos.count > 1 ? "Estas \(deletedTodos.count) tarefas serão apagadas" : "Esta tarefa será apagada"). Esta ação não poderá ser desfeita.",
                        isPresented: $showDeleteAllConfirmation,
                        titleVisibility: .visible
                    ) {
                        Button(role: .destructive) {
                            deleteAllTodos()
                        } label: {
                            Text("\(deletedTodos.count > 1 ? "Apagar \(deletedTodos.count) Tarefas" : "Apagar Tarefa")")
                        }
                    }
                    .confirmationDialog(
                        "\(selectedTodos.count > 1 ? "Estas \(selectedTodos.count) tarefas serão apagadas" : "Esta tarefa será apagada"). Esta ação não poderá ser desfeita.",
                        isPresented: $showDeleteSelectedConfirmation,
                        titleVisibility: .visible
                    ) {
                        Button(role: .destructive) {
                            deleteSelectedTodos()
                        } label: {
                            Text("\(selectedTodos.count > 1 ? "Apagar \(selectedTodos.count) Tarefas" : "Apagar Tarefa")")
                        }
                    }
//                }.padding(.bottom, 5)
            }
        }
        .onChange(of: deletedTodos) { _, newTodos in
            if newTodos.isEmpty {
                dismiss()
            }

            WidgetCenter.shared.reloadAllTimelines()
        }
        .onAppear {
            cleanExpiredTodos()
        }
    }

    // MARK: - Actions

    private func cleanExpiredTodos() {
        for todo in deletedTodos {
            guard let removalDate = Calendar.current.date(byAdding: .day, value: 30, to: todo.deletedAt ?? .now),
                  removalDate <= .now else { continue }

            withTransaction(Transaction(animation: nil)) {
                context.delete(todo)
            }
        }
    }

    private func deleteAllTodos() {
        for todo in deletedTodos {
            withAnimation { context.delete(todo) }
        }
    }

    private func deleteSelectedTodos() {
        for todo in selectedTodos {
            withAnimation { context.delete(todo) }
        }
        selectedTodos.removeAll()
    }

    private func restoreAllTodos() {
        for todo in deletedTodos {
            restore(todo)
        }
    }

    private func restoreSelectedTodos() {
        for todo in selectedTodos {
            restore(todo)
        }
        selectedTodos.removeAll()
    }

    private func restore(_ todo: ToDo) {
        withAnimation {
            todo.isToDoDeleted = false
            todo.deletedAt = nil
            if !todo.isCompleted, todo.dueDate > .now, !todo.isArchived {
                todo.scheduleNotification()
            }
        }
    }
}
