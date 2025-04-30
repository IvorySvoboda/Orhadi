//
//  SubjectsDataSettingsView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 23/04/25.
//

import SwiftData
import SwiftUI

struct SubjectsDataSettingsView: View {

    @Query(animation: .smooth) private var subjects: [Subject]

    // MARK: - Properties

    @State private var showDeleteConfirmation: Bool = false

    /// Exporter
    @State private var subjectsExportItem: SubjectTransferable?
    @State private var showSubjectsFileExporter: Bool = false

    /// Importer
    @State private var showSubjectsImportAlert: Bool = false
    @State private var showSubjectsFileImporter: Bool = false
    @State private var importedURL: URL?

    // MARK: - Computed Properties

    private var allSubjects: Int {
        subjects.filter({ !$0.isRecess }).count
    }

    private var allRecess: Int {
        subjects.filter({ $0.isRecess }).count
    }

    // MARK: - Views

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Total de Itens")
                    Spacer()
                    Text("\((subjects.count))")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Matérias")
                    Spacer()
                    Text("\(allSubjects)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Intervalos")
                    Spacer()
                    Text("\(allRecess)")
                        .foregroundStyle(.secondary)
                }
            }.listRowBackground(Color.orhadiSecondaryBG)

            Section {
                Button("Exportar Matérias") {
                    exportSubjects()
                }
                .disabled((subjects.isEmpty))
                .fileExporter(
                    isPresented: $showSubjectsFileExporter,
                    item: subjectsExportItem,
                    contentTypes: [.data],
                    defaultFilename: String(localized: "Matérias")
                ) { result in
                    switch result {
                    case .success(_):
                        subjectsExportItem = nil
                    case .failure(let error):
                        print(error.localizedDescription)
                        subjectsExportItem = nil
                    }
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
                        importedURL = url
                        importSubject()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }.listRowBackground(Color.orhadiSecondaryBG)

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
            }.listRowBackground(Color.orhadiSecondaryBG)
        }
        .orhadiListStyle()
        .navigationTitle("Matérias")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Actions

    /// Delete
    private func deleteAllSubjects() {
        Task.detached(priority: .background) {
            do {
                let context = ModelContext(try createContainer())

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
                let context = ModelContext(try createContainer())

                let descriptor = FetchDescriptor<Subject>()

                let allObjects = try context.fetch(descriptor)
                let exportItem = SubjectTransferable(subjects: allObjects)

                await UINotificationFeedbackGenerator().notificationOccurred(.success)

                await MainActor.run {
                    self.subjectsExportItem = exportItem
                    self.showSubjectsFileExporter = true
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

                let context = ModelContext(try createContainer())

                let existingSubjects = try context.fetch(FetchDescriptor<Subject>())
                for subject in existingSubjects { context.delete(subject) }

                let data = try Data(contentsOf: url)
                let allSubjects = try JSONDecoder().decode(
                    [Subject].self, from: data)

                for subject in allSubjects {
                    var teacher: Teacher? = nil

                    if let subjectTeacher = subject.teacher {
                        let existingTeacher = try context.fetch(FetchDescriptor<Teacher>(
                            predicate: #Predicate { $0.name == subjectTeacher.name }
                        )).first

                        if let existingTeacher {
                            teacher = existingTeacher
                        } else {
                            teacher = subjectTeacher
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
