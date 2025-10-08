//
//  ToDosDataSettingsView.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 23/04/25.
//

import SwiftData
import SwiftUI
import PopupView

struct ToDosDataSettingsView: View {
    @Query(filter: #Predicate<ToDo> {
        !$0.isToDoDeleted
    }, animation: .smooth) private var todos: [ToDo]

    // MARK: - Properties

    @State private var showDeleteConfirmation: Bool = false
    @State private var showErrorMessage: Bool = false
    @State private var errorMessage: String = ""

    /// Exporter
    @State private var todosExportItem: DataTransferable?
    @State private var showToDosFileExporter: Bool = false

    /// Importer
    @State private var showToDosImportAlert: Bool = false
    @State private var showToDosFileImporter: Bool = false
    @State private var importedURL: URL?

    // MARK: - Computed Properties

    private var completedTodos: Int {
        todos.filter({ $0.isCompleted && !$0.isArchived }).count
    }

    private var pendingTodos: Int {
        todos.filter({ $0.dueDate > .now && !$0.isCompleted && !$0.isArchived }).count
    }

    private var overdueTodos: Int {
        todos.filter({ $0.dueDate < .now && !$0.isCompleted && !$0.isArchived }).count
    }

    // MARK: - Views

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("All to-dos")
                    Spacer()
                    Text("\(todos.count)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Completed")
                    Spacer()
                    Text("\(completedTodos)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Overdue")
                    Spacer()
                    Text("\(overdueTodos)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Pending")
                    Spacer()
                    Text("\(pendingTodos)")
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Button("Export To-Dos") {
                    exportToDos()
                }
                .disabled(todos.isEmpty)
                .fileExporter(
                    isPresented: $showToDosFileExporter,
                    item: todosExportItem,
                    contentTypes: [.data],
                    defaultFilename: String(localized: "To-Dos")
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

                Button("Import To-Dos") {
                    showToDosImportAlert.toggle()
                }
                .alert("Import To-Dos?", isPresented: $showToDosImportAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Continue") {
                        showToDosFileImporter.toggle()
                    }
                } message: {
                    Text("When importing, all existing to-dos will be deleted. Do you wish to continue?")
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
            }

            Section {
                Button("Delete All to-dos") {
                    showDeleteConfirmation.toggle()
                }
                .tint(.red)
                .disabled(todos.isEmpty)
                .alert("Delete All to-dos?", isPresented: $showDeleteConfirmation) {
                    Button("Cancel", role: .cancel) {}
                    Button("Delete", role: .destructive) {
                        deleteAllToDo()
                    }
                }
            }
        }
        
        .navigationTitle("To-Dos")
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
                    NotificationsManager.shared.removePendingNotifications(withIdentifiers: todo.identifiers)

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
                let data = try JSONEncoder().encode(allObjects)
                let exportItem = DataTransferable(data: data)

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
        Task.detached(priority: .background) {
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
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

                /// Marcar All to-dos ativas como deletadas
                for todo in activeToDos {
                    NotificationsManager.shared.removePendingNotifications(withIdentifiers: todo.identifiers)

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
                        /// Restore a tarefa do lixo
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
                print(error)
            }
        }
    }

}
