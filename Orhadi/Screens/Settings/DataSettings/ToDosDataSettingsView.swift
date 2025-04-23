//
//  ToDosDataSettingsView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 23/04/25.
//

import SwiftData
import SwiftUI

struct ToDosDataSettingsView: View {
    @Environment(Settings.self) private var settings
    @Environment(OrhadiTheme.self) private var theme

    @Query(animation: .smooth) private var todos: [ToDo]

    @State private var showDeleteConfirmation: Bool = false
    /// Exporter
    @State private var todosExportItem: ToDoTransferable?
    @State private var showToDosFileExporter: Bool = false
    /// Importer
    @State private var showToDosImportAlert: Bool = false
    @State private var showToDosFileImporter: Bool = false
    @State private var importedURL: URL?

    var body: some View {
        Form {
            Section {
                let completed = self.todos.filter({ $0.isCompleted })
                let pending = self.todos.filter({ $0.dueDate < Date() && $0.dueDate.addingTimeInterval(settings.gracePeriod) > Date() && !$0.isCompleted })
                let expired = self.todos.filter({ $0.dueDate.addingTimeInterval(settings.gracePeriod) < Date() && !$0.isCompleted })
                let upcoming = self.todos.filter({ $0.dueDate > Date() && !$0.isCompleted })

                HStack {
                    Text("Total de tarefas")
                    Spacer()
                    Text("\(self.todos.count)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Concluídas")
                    Spacer()
                    Text("\(completed.count)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Pendentes")
                    Spacer()
                    Text("\(pending.count)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Atrasadas")
                    Spacer()
                    Text("\(expired.count)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Futuras")
                    Spacer()
                    Text("\(upcoming.count)")
                        .foregroundStyle(.secondary)
                }
            }.listRowBackground(theme.secondaryBGColor())

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
                    case .success(_):
                        print("Sucesso!")
                    case .failure(let error):
                        print(error.localizedDescription)
                    }

                    todosExportItem = nil
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
                    Text("Ao importar, todas as tarefas todas as tarefas existentes serão removidas. Deseja continuar?")
                }
                .fileImporter(
                    isPresented: $showToDosFileImporter,
                    allowedContentTypes: [.data]
                ) { result in
                    switch result {
                    case .success(let url):
                        debugPrint("Sucesso!")
                        importedURL = url
                        importToDos()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }.listRowBackground(theme.secondaryBGColor())

            Section {
                Button("Apagar todas as tarefas") {
                    showDeleteConfirmation.toggle()
                }.tint(.red)
                .alert("Apagar todas as tarefas?", isPresented: $showDeleteConfirmation) {
                    Button("Cancelar", role: .cancel) {}
                    Button("Apagar", role: .destructive) {
                        deleteAllToDo()
                    }
                }
            }.listRowBackground(theme.secondaryBGColor())
        }
        .modifier(DefaultList())
        .navigationTitle("Tarefas")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func deleteAllToDo() {
        Task.detached(priority: .background) {
            do {
                let context = try createContext()

                let todos = try context.fetch(FetchDescriptor<ToDo>())

                for todo in todos {
                    let todoID = todo.id
                    let identifiers = [
                        "\(todoID)-1h",
                        "\(todoID)-24h",
                        "\(todoID)-due",
                    ]

                    NotificationsManager.shared.removePendingNotifications(withIdentifiers: identifiers)

                    context.delete(todo)
                }

                try context.save()

                await UINotificationFeedbackGenerator().notificationOccurred(.success)
            } catch {
                print(error.localizedDescription)
                await UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }

    private func exportToDos() {
        Task.detached(priority: .background) {
            do {
                let context = try createContext()

                let descriptor = FetchDescriptor(sortBy: [SortDescriptor(\ToDo.dueDate, order: .forward)])

                let allObjects = try context.fetch(descriptor)
                let exportItem = ToDoTransferable(todos: allObjects)

                await UINotificationFeedbackGenerator().notificationOccurred(.success)

                await MainActor.run {
                    self.todosExportItem = exportItem
                    showToDosFileExporter = true
                }
            } catch {
                print(error.localizedDescription)
                await UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }

    private func importToDos() {
        guard let url = importedURL else { return }
        Task.detached(priority: .background) {
            do {
                guard url.startAccessingSecurityScopedResource() else { return }

                let context = try createContext()

                let settings = try context.fetch(FetchDescriptor<Settings>()).first ?? Settings()
                let existingToDos = try context.fetch(FetchDescriptor<ToDo>())

                for todo in existingToDos {
                    let todoID = todo.id
                    let identifiers = [
                        "\(todoID)-1h",
                        "\(todoID)-24h",
                        "\(todoID)-due",
                    ]

                    NotificationsManager.shared.removePendingNotifications(withIdentifiers: identifiers)

                    context.delete(todo)
                }

                let data = try Data(contentsOf: url)
                let allToDos = try JSONDecoder().decode(
                    [ToDo].self, from: data)

                for todo in allToDos {
                    if !todo.isCompleted, todo.dueDate.addingTimeInterval(settings.gracePeriod) > Date() {
                        todo.scheduleNotification()
                    }
                    context.insert(todo)
                }

                try context.save()

                debugPrint("Importado com sucesso!")

                url.stopAccessingSecurityScopedResource()

                await UINotificationFeedbackGenerator().notificationOccurred(.success)
            } catch {
                print(error.localizedDescription)
                await UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }
}
