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
    @Environment(OrhadiTheme.self) private var theme

    @Query(animation: .smooth) private var subjects: [Subject]
    @Query(animation: .smooth) private var todos: [ToDo]

    /// Exporter
    @State private var subjectsExportItem: SubjectTransferable?
    @State private var todosExportItem: ToDoTransferable?
    @State private var showSubjectsFileExporter: Bool = false
    @State private var showToDosFileExporter: Bool = false

    /// Importer
    @State private var showSubjectsImportAlert: Bool = false
    @State private var showToDosImportAlert: Bool = false
    @State private var showSubjectsFileImporter: Bool = false
    @State private var showToDosFileImporter: Bool = false
    @State private var importedURL: URL?

    var body: some View {
        Form {
            /// Subjects Import/Export
            Section {
                Button("Exportar Matérias") {
                    guard !showToDosFileExporter else { return }
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
                    guard !showToDosFileImporter else { return }
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
            .listRowBackground(theme.secondaryBGColor())

            /// To-Dos Import/Export
            Section {
                Button("Exportar Tarefas") {
                    guard !showSubjectsFileExporter else { return }
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
                    guard !showSubjectsFileImporter else { return }
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
            .listRowBackground(theme.secondaryBGColor())
        }
        .modifier(DefaultList())
        .navigationTitle("Dados")
        .navigationBarTitleDisplayMode(.inline)
    }

    /// Exporter
    private func exportSubjects() {
        Task.detached(priority: .background) {
            do {
                let databasePath = URL.documentsDirectory.appending(path: "database.store")

                let configuration = ModelConfiguration(url: databasePath)

                let container = try ModelContainer.init(
                    for: Schema(versionedSchema: CurrentSchema.self),
                    migrationPlan: MigrationPlan.self,
                    configurations: configuration
                )

                let context = ModelContext(container)

                let descriptor = FetchDescriptor<Subject>()

                let allObjects = try context.fetch(descriptor)
                let exportItem = SubjectTransferable(subjects: allObjects)

                debugPrint("Exportado com sucesso!")

                await UINotificationFeedbackGenerator().notificationOccurred(.success)

                await MainActor.run {
                    self.subjectsExportItem = exportItem
                    showSubjectsFileExporter = true
                }
            } catch {
                print(error.localizedDescription)
                await UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }

    private func exportToDos() {
        Task.detached(priority: .background) {
            do {
                let databasePath = URL.documentsDirectory.appending(path: "database.store")

                let configuration = ModelConfiguration(url: databasePath)

                let container = try ModelContainer.init(
                    for: Schema(versionedSchema: CurrentSchema.self),
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

    /// Importer
    private func importSubject() {
        guard let url = importedURL else { return }
        Task.detached(priority: .background) {
            do {
                guard url.startAccessingSecurityScopedResource() else { return }

                let databasePath = URL.documentsDirectory.appending(path: "database.store")

                let configuration = ModelConfiguration(url: databasePath)

                let container = try ModelContainer.init(
                    for: Schema(versionedSchema: CurrentSchema.self),
                    migrationPlan: MigrationPlan.self,
                    configurations: configuration
                )

                let context = ModelContext(container)

                try context.delete(model: Subject.self)

                let data = try Data(contentsOf: url)
                let allSubjects = try JSONDecoder().decode(
                    [Subject].self, from: data)

                for subject in allSubjects {
                    var teacher: Teacher? = nil

                    if let name = subject.teacher?.name, let email = subject.teacher?.email, !name.isEmpty || !email.isEmpty {
                        let existingTeacher = try? context.fetch(
                            FetchDescriptor<Teacher>(
                                predicate: #Predicate { $0.name == name }
                            )
                        ).first

                        if let foundTeacher = existingTeacher {
                            teacher = foundTeacher
                        } else {
                            teacher = Teacher(
                                name: name,
                                email: email
                            )
                            context.insert(teacher!)
                        }
                    }

                    context.insert(
                        Subject(
                            name: subject.name,
                            teacher: teacher,
                            schedule: subject.schedule,
                            startTime: subject.startTime,
                            endTime: subject.endTime,
                            place: subject.place,
                            isRecess: subject.isRecess
                        )
                    )
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

    private func importToDos() {
        guard let url = importedURL else { return }
        Task.detached(priority: .background) {
            do {
                guard url.startAccessingSecurityScopedResource() else { return }

                let databasePath = URL.documentsDirectory.appending(path: "database.store")

                let configuration = ModelConfiguration(url: databasePath)

                let container = try ModelContainer.init(
                    for: Schema(versionedSchema: CurrentSchema.self),
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
                    await scheduleNotification(for: todo)
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

}
