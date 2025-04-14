//
//  DataSettingsView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 02/04/25.
//

import SwiftData
import SwiftUI

struct DataSettingsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(Settings.self) private var settings

    @Query(animation: .smooth) private var subjects: [Subject]
    @Query(animation: .smooth) private var todos: [ToDo]
    @Query(animation: .smooth) private var srsubjects: [SRSubject]

    /// Exporter
    @State private var subjectsExportItem: SubjectTransferable?
    @State private var todosExportItem: ToDoTransferable?
    @State private var srSubjecsExportItem: SRSubjectTransferable?
    @State private var showSubjectsFileExporter: Bool = false
    @State private var showToDosFileExporter: Bool = false
    @State private var showSRSubjectsFileExporter: Bool = false
    /// Importer
    @State private var showSubjectsImportAlert: Bool = false
    @State private var showToDosImportAlert: Bool = false
    @State private var showSRSubjectsImportAlert: Bool = false
    @State private var showSubjectsFileImporter: Bool = false
    @State private var showToDosFileImporter: Bool = false
    @State private var showSRSubjectsFileImporter: Bool = false
    @State private var importedURL: URL?

    var body: some View {
        Form {
            /// Subjects Import/Export
            Section {
                Button("Exportar Matérias") {
                    guard !showToDosFileExporter || !showSRSubjectsFileExporter
                    else { return }
                    exportSubjects()
                }
                .disabled(subjects.isEmpty)
                .fileExporter(
                    isPresented: $showSubjectsFileExporter,
                    item: subjectsExportItem,
                    contentTypes: [.data],
                    defaultFilename: String(localized: "Matérias")
                ) { result in
                    switch result {
                    case .success(_):
                        print("Sucesso!")
                    case .failure(let error):
                        print(error.localizedDescription)
                    }

                    subjectsExportItem = nil
                } onCancellation: {
                    subjectsExportItem = nil
                }

                Button("Importar Matérias") {
                    guard !showToDosFileImporter || !showSRSubjectsFileImporter
                    else { return }
                    showSubjectsImportAlert.toggle()
                }
                .alert(
                    "Importar Matérias", isPresented: $showSubjectsImportAlert,
                    actions: {
                        Button("Cancelar", role: .cancel) {}
                        Button("Continuar") {
                            showSubjectsFileImporter.toggle()
                        }
                    },
                    message: {
                        Text(
                            "Ao importar as matérias todas as matérias já existentes serão removidas. Deeseja continuar?"
                        )
                    }
                )
                .fileImporter(
                    isPresented: $showSubjectsFileImporter,
                    allowedContentTypes: [.data]
                ) { result in
                    switch result {
                    case .success(let url):
                        debugPrint("Sucesso!")
                        importedURL = url
                        importSubject()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            } header: {
                Text("Matérias")
            }
            .listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))

            /// To-Dos Import/Export
            Section {
                Button("Exportar Tarefas") {
                    guard
                        !showSubjectsFileExporter || !showSRSubjectsFileExporter
                    else { return }
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
                    guard
                        !showSubjectsFileImporter || !showSRSubjectsFileImporter
                    else { return }
                    showToDosImportAlert.toggle()
                }
                .alert(
                    "Importar Tarefas", isPresented: $showToDosImportAlert,
                    actions: {
                        Button("Cancelar", role: .cancel) {}
                        Button("Continuar") {
                            showToDosFileImporter.toggle()
                        }
                    },
                    message: {
                        Text(
                            "Ao importar as tarefas todas as tarefas já existentes serão removidas. Deeseja continuar?"
                        )
                    }
                )
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
            } header: {
                Text("Tarefas")
            }
            .listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))

            /// Study Routine Subjects Import/Export
            Section {
                Button("Exportar Rotina de Estudos") {
                    guard !showToDosFileExporter || !showSubjectsFileExporter
                    else { return }
                    exportSRSubjects()
                }
                .disabled(srsubjects.isEmpty)
                .fileExporter(
                    isPresented: $showSRSubjectsFileExporter,
                    item: srSubjecsExportItem,
                    contentTypes: [.data],
                    defaultFilename: String(localized: "Rotina de Estudos")
                ) { result in
                    switch result {
                    case .success(_):
                        print("Sucesso!")
                    case .failure(let error):
                        print(error.localizedDescription)
                    }

                    srSubjecsExportItem = nil
                } onCancellation: {
                    srSubjecsExportItem = nil
                }

                Button("Importar Rotina de Estudos") {
                    guard !showToDosFileImporter || !showSubjectsFileImporter
                    else { return }
                    showSRSubjectsImportAlert.toggle()
                }
                .alert(
                    "Importar Rotina de Estudos",
                    isPresented: $showSRSubjectsImportAlert,
                    actions: {
                        Button("Cancelar", role: .cancel) {}
                        Button("Continuar") {
                            showSRSubjectsFileImporter.toggle()
                        }
                    },
                    message: {
                        Text(
                            "Ao importar a rotina de estudos todas as informações existentes da rotina de estudos serão removidas. Deeseja continuar?"
                        )
                    }
                )
                .fileImporter(
                    isPresented: $showSRSubjectsFileImporter,
                    allowedContentTypes: [.data]
                ) { result in
                    switch result {
                    case .success(let url):
                        debugPrint("Sucesso!")
                        importedURL = url
                        importSRSubjects()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            } header: {
                Text("Rotina de Estudos")
            }
            .listRowBackground(OrhadiTheme.getSecondaryBGColor(for: colorScheme))
        }
        .background(OrhadiTheme.getBGColor(for: colorScheme))
        .scrollContentBackground(.hidden)
        .navigationTitle("Dados")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(
            OrhadiTheme.getBGColor(for: colorScheme),
            for: .navigationBar)
    }

    /// Exporter
    private func exportSubjects() {
        Task.detached(priority: .background) {
            do {
                let databasePath = URL.documentsDirectory.appending(path: "database.store")

                let configuration = ModelConfiguration(url: databasePath)

                let container = try ModelContainer.init(
                    for: Subject.self, SRSubject.self, ToDo.self, Settings.self, Teacher.self,
                    migrationPlan: MigrationPlan.self,
                    configurations: configuration
                )

                let context = ModelContext(container)

                let descriptor = FetchDescriptor(sortBy: [
                    .init(\Subject.startTime, order: .forward)
                ])

                let allObjects = try context.fetch(descriptor)
                let exportItem = SubjectTransferable(subjects: allObjects)

                debugPrint("Exportado com sucesso!")

                await MainActor.run {
                    self.subjectsExportItem = exportItem
                    showSubjectsFileExporter = true
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    private func exportToDos() {
        Task.detached(priority: .background) {
            do {
                let databasePath = URL.documentsDirectory.appending(path: "database.store")

                let configuration = ModelConfiguration(url: databasePath)

                let container = try ModelContainer.init(
                    for: Subject.self, SRSubject.self, ToDo.self, Settings.self, Teacher.self,
                    migrationPlan: MigrationPlan.self,
                    configurations: configuration
                )

                let context = ModelContext(container)

                let descriptor = FetchDescriptor(sortBy: [
                    .init(\ToDo.dueDate, order: .forward)
                ])

                let allObjects = try context.fetch(descriptor)
                let exportItem = ToDoTransferable(todos: allObjects)

                debugPrint("Exportado com sucesso!")

                await MainActor.run {
                    self.todosExportItem = exportItem
                    showToDosFileExporter = true
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    private func exportSRSubjects() {
        Task.detached(priority: .background) {
            do {
                let databasePath = URL.documentsDirectory.appending(path: "database.store")

                let configuration = ModelConfiguration(url: databasePath)

                let container = try ModelContainer.init(
                    for: Subject.self, SRSubject.self, ToDo.self, Settings.self, Teacher.self,
                    migrationPlan: MigrationPlan.self,
                    configurations: configuration
                )

                let context = ModelContext(container)

                let descriptor = FetchDescriptor(sortBy: [
                    .init(\SRSubject.studyDay, order: .forward)
                ])

                let allObjects = try context.fetch(descriptor)
                let exportItem = SRSubjectTransferable(subjects: allObjects)

                debugPrint("Exportado com sucesso!")

                await MainActor.run {
                    self.srSubjecsExportItem = exportItem
                    showSRSubjectsFileExporter = true
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    /// Importer
    private func importSubject() {
        guard let url = importedURL else { return }
        Task.detached(priority: .background) {
            do {
                guard url.startAccessingSecurityScopedResource() else { return }

                let databasePath = URL.documentsDirectory.appending(path: "database.store")

                let configuration = ModelConfiguration(url: databasePath)

                let container = try ModelContainer.init(
                    for: Subject.self, SRSubject.self, ToDo.self, Settings.self, Teacher.self,
                    migrationPlan: MigrationPlan.self,
                    configurations: configuration
                )

                let context = ModelContext(container)

                let descriptor = FetchDescriptor<Subject>()

                let existingSubjects = try context.fetch(descriptor)
                for subject in existingSubjects {
                    context.delete(subject)
                }

                let data = try Data(contentsOf: url)
                let allSubjects = try JSONDecoder().decode(
                    [Subject].self, from: data)

                for subject in allSubjects {
                    context.insert(subject)
                }

                try context.save()

                debugPrint("Importado com sucesso!")

                url.stopAccessingSecurityScopedResource()
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    private func importToDos() {
        guard let url = importedURL else { return }
        Task.detached(priority: .background) {
            do {
                guard url.startAccessingSecurityScopedResource() else { return }

                let databasePath = URL.documentsDirectory.appending(path: "database.store")

                let configuration = ModelConfiguration(url: databasePath)

                let container = try ModelContainer.init(
                    for: Subject.self, SRSubject.self, ToDo.self, Settings.self, Teacher.self,
                    migrationPlan: MigrationPlan.self,
                    configurations: configuration
                )

                let context = ModelContext(container)

                let descriptor = FetchDescriptor<ToDo>()
                let existingToDos = try context.fetch(descriptor)

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
                    scheduleNotification(for: todo)
                    context.insert(todo)
                }

                try context.save()

                debugPrint("Importado com sucesso!")

                url.stopAccessingSecurityScopedResource()
            } catch {
                print(error.localizedDescription)
            }
        }

        func scheduleNotification(for todo: ToDo) {
            if !todo.isCompleted && settings.scheduleNotifications {
                if let oneHourBefore = Calendar.current.date(
                    byAdding: .hour, value: -1, to: todo.dueDate
                ) {
                    NotificationsManager.shared.addNotification(
                        identifier: "\(todo.id)-1h",
                        title: "Lembrete: Falta 1 hora!",
                        body: "Tarefa: \(todo.title) vence em 1 hora.",
                        date: oneHourBefore
                    )
                }

                if let twentyFourHoursBefore = Calendar.current.date(
                    byAdding: .hour, value: -24, to: todo.dueDate
                ) {
                    NotificationsManager.shared.addNotification(
                        identifier: "\(todo.id)-24h",
                        title: "Lembrete: Falta 1 dia!",
                        body:
                            "Tarefa: \(todo.title) vence em 24 horas.",
                        date: twentyFourHoursBefore
                    )
                }

                NotificationsManager.shared.addNotification(
                    identifier: "\(todo.id)-due",
                    title: "A Tarefa Venceu!",
                    body: "Tarefa: \(todo.title) Venceu!",
                    date: todo.dueDate
                )
            }
        }
    }

    private func importSRSubjects() {
        guard let url = importedURL else { return }
        Task.detached(priority: .background) {
            do {
                guard url.startAccessingSecurityScopedResource() else { return }

                let databasePath = URL.documentsDirectory.appending(path: "database.store")

                let configuration = ModelConfiguration(url: databasePath)

                let container = try ModelContainer.init(
                    for: Subject.self, SRSubject.self, ToDo.self, Settings.self, Teacher.self,
                    migrationPlan: MigrationPlan.self,
                    configurations: configuration
                )

                let context = ModelContext(container)

                let descriptor = FetchDescriptor(sortBy: [
                    .init(\SRSubject.studyDay, order: .forward)
                ])

                let existingSubjects = try context.fetch(descriptor)
                for subject in existingSubjects {
                    context.delete(subject)
                }

                let data = try Data(contentsOf: url)
                let allSubjects = try JSONDecoder().decode(
                    [SRSubject].self, from: data)

                debugPrint(allSubjects.count)

                for subject in allSubjects {
                    context.insert(subject)
                }

                try context.save()

                debugPrint("Importado com sucesso!")

                url.stopAccessingSecurityScopedResource()
            } catch {
                print(error.localizedDescription)
            }
        }
    }

}
