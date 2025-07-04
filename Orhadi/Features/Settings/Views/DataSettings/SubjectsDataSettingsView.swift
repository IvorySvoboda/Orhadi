//
//  SubjectsDataSettingsView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 23/04/25.
//

import SwiftData
import SwiftUI
import PopupView

struct SubjectsDataSettingsView: View {

    @Query(filter: #Predicate<Subject> {
        !$0.isSubjectDeleted
    }, animation: .smooth) private var subjects: [Subject]

    // MARK: - Properties

    @State private var showDeleteConfirmation: Bool = false
    @State private var showErrorMessage: Bool = false
    @State private var errorMessage: String = ""

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
            }.orhadiListRowBackground()

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
                    case .success:
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
                    Text("Ao importar, todas as matérias existentes serão apagadas. Deseja continuar?")
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
            }.orhadiListRowBackground()

            Section {
                Button("Apagar todas as matérias") {
                    showDeleteConfirmation.toggle()
                }
                .tint(.red)
                .disabled(subjects.isEmpty)
                .alert("Apagar todas as matérias?", isPresented: $showDeleteConfirmation) {
                    Button("Cancelar", role: .cancel) {}
                    Button("Apagar", role: .destructive) {
                        deleteAllSubjects()
                    }
                }
            }.orhadiListRowBackground()
        }
        .orhadiListStyle()
        .navigationTitle("Matérias")
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

    /// Delete
    private func deleteAllSubjects() {
        Task.detached(priority: .background) {
            do {
                let context = ModelContext(try createContainer())

                let subjects = try context.fetch(FetchDescriptor<Subject>(predicate: #Predicate<Subject> {
                    !$0.isSubjectDeleted
                }))

                for subject in subjects {
                    subject.isSubjectDeleted = true
                    subject.deletedAt = .now
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

    /// Exporter
    private func exportSubjects() {
        Task.detached(priority: .background) {
            do {
                let context = ModelContext(try createContainer())

                let descriptor = FetchDescriptor<Subject>(predicate: #Predicate<Subject> {
                    !$0.isSubjectDeleted
                })

                let allObjects = try context.fetch(descriptor)
                let exportItem = SubjectTransferable(subjects: allObjects)

                await UINotificationFeedbackGenerator().notificationOccurred(.success)

                await MainActor.run {
                    self.subjectsExportItem = exportItem
                    self.showSubjectsFileExporter = true
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            }
        }
    }

    /// Importer
    private func importSubject() {
        guard let url = importedURL else { return }
        Task.detached(priority: .background) {
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            do {
                let context = ModelContext(try createContainer())

                let data = try Data(contentsOf: url)
                let importedSubjects = try JSONDecoder().decode(
                    [Subject].self, from: data)

                var deletedSubjects = try context.fetch(FetchDescriptor<Subject>(predicate: #Predicate<Subject> {
                    $0.isSubjectDeleted
                }))

                let existingSubjects = try context.fetch(FetchDescriptor<Subject>(predicate: #Predicate<Subject> {
                    !$0.isSubjectDeleted
                }))

                for subject in existingSubjects {
                    subject.isSubjectDeleted = true
                    subject.deletedAt = .now

                    deletedSubjects.append(subject)
                }

                for subject in importedSubjects {
                    var teacher: Teacher?

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

                    if let matchInTrash = deletedSubjects.first(where: {
                        $0.name == subject.name &&
                        Calendar.current.isDate($0.startTime, equalTo: subject.startTime, toGranularity: .minute) &&
                        Calendar.current.isDate($0.endTime, equalTo: subject.endTime, toGranularity: .minute) &&
                        Calendar.current.isDate($0.schedule, equalTo: subject.schedule, toGranularity: .minute) &&
                        $0.isRecess == subject.isRecess &&
                        $0.teacher == teacher &&
                        $0.place == subject.place
                    }) {
                        matchInTrash.isSubjectDeleted = false
                        matchInTrash.deletedAt = nil
                    } else {
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
                }

                try context.save()

                await MainActor.run {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            }
        }
    }
}
