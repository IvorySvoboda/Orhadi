//
//  SubjectsDataSettingsView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 23/04/25.
//

import SwiftData
import SwiftUI

struct SubjectsDataSettingsView: View {
    @Environment(OrhadiTheme.self) private var theme

    @Query(animation: .smooth) private var subjects: [Subject]

    @State private var showDeleteConfirmation: Bool = false
    /// Exporter
    @State private var subjectsExportItem: SubjectTransferable?
    @State private var showSubjectsFileExporter: Bool = false
    /// Importer
    @State private var showSubjectsImportAlert: Bool = false
    @State private var showSubjectsFileImporter: Bool = false
    @State private var importedURL: URL?

    var body: some View {
        Form {
            Section {
                let subjects = self.subjects.filter({ !$0.isRecess })
                let recess = self.subjects.filter({ $0.isRecess })

                HStack {
                    Text("Total de Itens")
                    Spacer()
                    Text("\(self.subjects.count)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Matérias")
                    Spacer()
                    Text("\(subjects.count)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Intervalos")
                    Spacer()
                    Text("\(recess.count)")
                        .foregroundStyle(.secondary)
                }
            }.listRowBackground(theme.secondaryBGColor())

            Section {
                Button("Exportar Matérias") {
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
                    showSubjectsImportAlert.toggle()
                }
                .alert("Importar Matérias?", isPresented: $showSubjectsImportAlert) {
                    Button("Cancelar", role: .cancel) {}
                    Button("Continuar") {
                        showSubjectsFileImporter.toggle()
                    }
                } message: {
                    Text("Ao importar, todas as matérias todas as matérias existentes serão removidas. Deseja continuar?")
                }
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
            }.listRowBackground(theme.secondaryBGColor())

            Section {
                Button("Apagar todas as matérias") {
                    showDeleteConfirmation.toggle()
                }.tint(.red)
                .alert("Apagar todas as matérias?", isPresented: $showDeleteConfirmation) {
                    Button("Cancelar", role: .cancel) {}
                    Button("Apagar", role: .destructive) {
                        deleteAllSubjects()
                    }
                }
            }.listRowBackground(theme.secondaryBGColor())
        }
        .modifier(DefaultList())
        .navigationTitle("Matérias")
        .navigationBarTitleDisplayMode(.inline)
    }

    /// Delete
    private func deleteAllSubjects() {
        Task.detached(priority: .background) {
            do {
                let context = try createContext()

                let subjects = try context.fetch(FetchDescriptor<Subject>())

                for subject in subjects {
                    context.delete(subject)
                }

                try context.save()

                await UINotificationFeedbackGenerator().notificationOccurred(.success)
            } catch {
                print(error.localizedDescription)
                await UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }

    /// Exporter
    private func exportSubjects() {
        Task.detached(priority: .background) {
            do {
                let context = try createContext()

                let descriptor = FetchDescriptor<Subject>()

                let allObjects = try context.fetch(descriptor)
                let exportItem = SubjectTransferable(subjects: allObjects)

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

    /// Importer
    private func importSubject() {
        guard let url = importedURL else { return }
        Task.detached(priority: .background) {
            do {
                guard url.startAccessingSecurityScopedResource() else { return }

                let context = try createContext()

                let existingSubjects = try context.fetch(FetchDescriptor<Subject>())
                for subject in existingSubjects { context.delete(subject) }

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

                url.stopAccessingSecurityScopedResource()

                await UINotificationFeedbackGenerator().notificationOccurred(.success)
            } catch {
                print(error.localizedDescription)
                await UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }
}
