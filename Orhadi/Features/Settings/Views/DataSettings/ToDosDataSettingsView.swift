//
//  ToDosDataSettingsView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 23/04/25.
//

import SwiftData
import SwiftUI
import PopupView

struct ToDosDataSettingsView: View {
    @Query(filter: #Predicate<ToDo> {
        !$0.isToDoDeleted && !$0.isArchived
    }, animation: .smooth) private var todos: [ToDo]

    // MARK: - Properties

    @State private var showDeleteConfirmation: Bool = false
    @State private var showErrorMessage: Bool = false
    @State private var errorMessage: String = ""

    /// Exporter
    @State private var todosExportItem: ToDoTransferable?
    @State private var showToDosFileExporter: Bool = false

    /// Importer
    @State private var showToDosImportAlert: Bool = false
    @State private var showToDosFileImporter: Bool = false
    @State private var importedURL: URL?

    // MARK: - Computed Properties

    private var completedTodos: Int {
        todos.filter({ $0.isCompleted }).count
    }

    private var pendingTodos: Int {
        todos.filter({ $0.dueDate > .now && !$0.isCompleted }).count
    }

    private var overdueTodos: Int {
        todos.filter({ $0.dueDate < .now && !$0.isCompleted }).count
    }

    // MARK: - Views

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Total de tarefas")
                    Spacer()
                    Text("\(todos.count)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Concluídas")
                    Spacer()
                    Text("\(completedTodos)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Atrasadas")
                    Spacer()
                    Text("\(overdueTodos)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("A Fazer")
                    Spacer()
                    Text("\(pendingTodos)")
                        .foregroundStyle(.secondary)
                }
            }.listRowBackground(Color.orhadiSecondaryBG)

            Section {
                Button("Exportar Tarefas") {
                    exportToDos()
                }
                .disabled(todos.isEmpty)
                .fileExporter(
                    isPresented: $showToDosFileExporter,
                    item: todosExportItem,
                    contentTypes: [.data],
                    defaultFilename: String(localized: "Tarefas")
                ) { result in
                    switch result {
                    case .success:
                        todosExportItem = nil
                    case .failure(let error):
                        print(error.localizedDescription)
                        todosExportItem = nil
                    }
                } onCancellation: {
                    todosExportItem = nil
                }

                Button("Importar Tarefas") {
                    showToDosImportAlert.toggle()
                }
                .alert("Importar Tarefas?", isPresented: $showToDosImportAlert) {
                    Button("Cancelar", role: .cancel) {}
                    Button("Continuar") {
                        showToDosFileImporter.toggle()
                    }
                } message: {
                    Text("Ao importar, todas as tarefas existentes serão apagadas. Deseja continuar?")
                }
                .fileImporter(
                    isPresented: $showToDosFileImporter,
                    allowedContentTypes: [.data]
                ) { result in
                    switch result {
                    case .success(let url):
                        importedURL = url
                        importToDos()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }.listRowBackground(Color.orhadiSecondaryBG)

            Section {
                Button("Apagar todas as tarefas") {
                    showDeleteConfirmation.toggle()
                }
                .tint(.red)
                .disabled(todos.isEmpty)
                .alert("Apagar todas as tarefas?", isPresented: $showDeleteConfirmation) {
                    Button("Cancelar", role: .cancel) {}
                    Button("Apagar", role: .destructive) {
                        deleteAllToDo()
                    }
                }
            }.listRowBackground(Color.orhadiSecondaryBG)
        }
        .orhadiListStyle()
        .navigationTitle("Tarefas")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: errorMessage, { _, _ in
            if !errorMessage.isEmpty {
                showErrorMessage = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    errorMessage = ""
                }
            }
        })
        .popup(isPresented: $showErrorMessage) {
            Text(errorMessage)
                .foregroundColor(.white)
                .padding(EdgeInsets(top: 60, leading: 5, bottom: 16, trailing: 5))
                .frame(maxWidth: .infinity)
                .background(Color.red)
        } customize: {
            $0
                .type(.toast)
                .position(.top)
                .animation(.smooth)
                .autohideIn(2)
        }
    }

    // MARK: - Actions

    private func deleteAllToDo() {
        Task.detached(priority: .background) {
            do {
                let context = ModelContext(try createContainer())

                let todos = try context.fetch(FetchDescriptor<ToDo>(predicate: #Predicate<ToDo> {
                    !$0.isToDoDeleted
                }))

                for todo in todos {
                    let todoID = todo.id
                    let identifiers = [
                        "\(todoID)-1h",
                        "\(todoID)-24h",
                        "\(todoID)-due"
                    ]

                    NotificationsManager.shared.removePendingNotifications(withIdentifiers: identifiers)

                    todo.isToDoDeleted = true
                    todo.deletedAt = .now
                }

                try context.save()

                await UINotificationFeedbackGenerator().notificationOccurred(.success)
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            }
        }
    }

    private func exportToDos() {
        Task.detached(priority: .background) {
            do {
                let context = ModelContext(try createContainer())

                let descriptor = FetchDescriptor(predicate: #Predicate<ToDo> {
                    !$0.isToDoDeleted
                })

                let allObjects = try context.fetch(descriptor)
                let exportItem = ToDoTransferable(todos: allObjects)

                await UINotificationFeedbackGenerator().notificationOccurred(.success)

                await MainActor.run {
                    self.todosExportItem = exportItem
                    self.showToDosFileExporter = true
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            }
        }
    }

    private func importToDos() {
        guard let url = importedURL else { return }
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        Task.detached(priority: .background) {
            do {
                let context = ModelContext(try createContainer())

                let data = try Data(contentsOf: url)
                let importedTodos = try JSONDecoder().decode([ToDo].self, from: data)

                var deletedToDos = try context.fetch(FetchDescriptor<ToDo>(predicate: #Predicate<ToDo> {
                    $0.isToDoDeleted
                }))

                let activeToDos = try context.fetch(FetchDescriptor<ToDo>(predicate: #Predicate<ToDo> {
                    !$0.isToDoDeleted
                }))

                /// Marcar todas as tarefas ativas como deletadas
                for todo in activeToDos {
                    let todoID = todo.id
                    let identifiers = [
                        "\(todoID)-1h",
                        "\(todoID)-24h",
                        "\(todoID)-due"
                    ]

                    NotificationsManager.shared.removePendingNotifications(withIdentifiers: identifiers)

                    todo.isToDoDeleted = true
                    todo.deletedAt = .now

                    deletedToDos.append(todo)
                }

                for imported in importedTodos {
                    /// Verificar se há uma tarefa no lixo com mesmo conteúdo
                    if let matchInTrash = deletedToDos.first(where: {
                        $0.title == imported.title &&
                        Calendar.current.isDate($0.dueDate, equalTo: imported.dueDate, toGranularity: .minute) &&
                        $0.info == imported.info
                    }) {
                        /// Restaurar a tarefa do lixo
                        matchInTrash.isToDoDeleted = false
                        matchInTrash.deletedAt = nil
                        matchInTrash.isCompleted = imported.isCompleted
                        if !matchInTrash.isCompleted, matchInTrash.dueDate > .now {
                            matchInTrash.scheduleNotification()
                        }
                    } else {
                        /// Nova tarefa
                        if !imported.isCompleted, imported.dueDate > .now {
                            imported.scheduleNotification()
                        }
                        context.insert(imported)
                    }
                }

                try context.save()

                await MainActor.run {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
            } catch {
                await MainActor.run {
                    errorMessage = "\(error.localizedDescription)"
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            }
        }
    }

}
