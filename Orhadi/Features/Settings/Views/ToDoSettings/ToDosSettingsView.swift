//
//  TasksSettingsView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 01/04/25.
//

import SwiftUI
import SwiftData

struct ToDosSettingsView: View {

    @Query private var todos: [ToDo]

    @State private var notificationStatus: Bool = false

    @Bindable var settings: Settings

    var deletedTodos: [ToDo] {
        todos.filter {
            $0.isToDoDeleted
        }
    }

    var body: some View {
        Form {
            Section {
                Toggle(
                    "Agendar Notificações",
                    isOn: $settings.scheduleNotifications
                ).disabled(!notificationStatus)
            } header: {
                Text("Notificações")
            } footer: {
                Text(
                    "Quando ativado, notificações serão agendadas para lembrar você de tarefas próximas ao prazo final. Desativar essa opção não cancelará notificações já agendadas."
                )
            }
            .listRowBackground(Color.orhadiSecondaryBG)

            if !deletedTodos.isEmpty {
                Section {
                    NavigationLink {
                        DeletedTodosView()
                    } label: {
                        Text("Tarefas Apagadas")
                    }
                }.listRowBackground(Color.orhadiSecondaryBG)
            }
        }
        .orhadiListStyle()
        .navigationTitle("Tarefas")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            NotificationsManager.shared.notificationStatus { authorizedStatus in
                self.notificationStatus = authorizedStatus
                if !notificationStatus {
                    settings.scheduleNotifications = false
                }
            }
        }
    }
}

struct DeletedTodosView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode

    @Query(filter: #Predicate<ToDo> { $0.isToDoDeleted }, sort: \.deletedAt, animation: .smooth)
    private var deletedTodos: [ToDo]

    @State private var selectedTodos = Set<ToDo>()
    @State private var showDeleteAllConfirmation = false
    @State private var showDeleteSelectedConfirmation = false
    @State private var isBottomBarVisible: Bool = false

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
                .listRowBackground(Color.orhadiSecondaryBG)
            }
        }
        .orhadiListStyle()
        .navigationTitle("Tarefas Apagadas")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.visible, for: .bottomBar)
        .toolbarBackground(Color.orhadiBG, for: .bottomBar)
        .toolbarVisibility(editMode?.wrappedValue.isEditing == true ? .visible : .hidden, for: .bottomBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }

            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Button(selectedTodos.isEmpty ? "Restaurar Todas" : "Restaurar") {
                        selectedTodos.isEmpty ? restoreAllTodos() : restoreSelectedTodos()
                    }

                    Spacer()

                    Button(selectedTodos.isEmpty ? "Apagar Tudo" : "Apagar") {
                        selectedTodos.isEmpty ? (showDeleteAllConfirmation = true) : (showDeleteSelectedConfirmation = true)
                    }
                }.padding(.bottom, 5)
            }
        }
        .confirmationDialog("\(deletedTodos.count > 1 ? "Estas \(deletedTodos.count) tarefas serão apagadas." : "Esta tarefa será apagada"). Esta ação não poderá ser desfeita.", isPresented: $showDeleteAllConfirmation, titleVisibility: .visible, actions: {
            Button("\(deletedTodos.count > 1 ? "Apagar \(deletedTodos.count) Tarefas" : "Apagar Tarefa")", role: .destructive) {
                deleteAllTodos()
            }
        })
        .confirmationDialog("\(selectedTodos.count > 1 ? "Estas \(selectedTodos.count) tarefas serão apagadas" : "Esta tarefa será apagada"). Esta ação não poderá ser desfeita.", isPresented: $showDeleteSelectedConfirmation, titleVisibility: .visible, actions: {
            Button("\(selectedTodos.count > 1 ? "Apagar \(selectedTodos.count) Tarefas" : "Apagar Tarefa")", role: .destructive) {
                deleteSelectedTodos()
            }
        })
        .onChange(of: deletedTodos) { _, newTodos in
            if newTodos.isEmpty {
                dismiss()
            }
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
            if !todo.isCompleted, todo.dueDate > .now {
                todo.scheduleNotification()
            }
        }
    }
}

struct DeletedTodosRowView: View {
    @Environment(\.modelContext) private var context
    @State private var showDeleteConfirmation = false

    let todo: ToDo

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(todo.title.nilIfEmpty() ?? String(localized: "Não Informado"))
                    .font(.headline)
                    .lineLimit(1)

                CustomLabel("\(todo.deletedAt?.formatted(date: .abbreviated, time: .shortened) ?? "")", systemImage: "trash.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                showDeleteConfirmation.toggle()
            } label: {
                Label("Apagar", systemImage: "trash.fill")
                    .labelStyle(.iconOnly)
            }.tint(.red)

            Button(role: .destructive) {
                recoverTodo()
            } label: {
                Label("Recuperar", systemImage: "gobackward")
                    .labelStyle(.iconOnly)
            }.tint(.indigo)
        }
        .confirmationDialog("Esta tarefa será apagada. Esta ação não poderá ser desfeita.",
                            isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Apagar Tarefa", role: .destructive) {
                withAnimation {
                    context.delete(todo)
                }
            }
        }
    }

    private func recoverTodo() {
        withAnimation {
            todo.isToDoDeleted = false
            todo.deletedAt = nil
            todo.scheduleNotification()
        }
    }
}
