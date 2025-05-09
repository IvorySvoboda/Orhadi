//
//  SRDataSettingsView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 23/04/25.
//

import SwiftData
import SwiftUI
import PopupView

struct SRDataSettingsView: View {

    @Query(filter: #Predicate<SRStudy> {
        !$0.isStudyDeleted
    }, animation: .smooth) private var studies: [SRStudy]

    // MARK: - Properties

    @State private var showDeleteConfirmation: Bool = false
    @State private var showErrorMessage: Bool = false
    @State private var errorMessage: String = ""

    /// Exporter
    @State private var srExportItem: SRStudyTransferable?
    @State private var showSRFileExporter: Bool = false

    /// Importer
    @State private var showSRImportAlert: Bool = false
    @State private var showSRFileImporter: Bool = false
    @State private var importedURL: URL?

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Total de Estudos")
                    Spacer()
                    Text("\(studies.count)")
                        .foregroundStyle(.secondary)
                }
            }.listRowBackground(Color.orhadiSecondaryBG)

            Section {
                Button("Exportar Rotina de Estudos") {
                    exportSR()
                }
                .disabled(studies.isEmpty)
                .fileExporter(
                    isPresented: $showSRFileExporter,
                    item: srExportItem,
                    contentTypes: [.data],
                    defaultFilename: String(localized: "Rotina de Estudos")
                ) { result in
                    switch result {
                    case .success:
                        print("Sucesso!")
                        srExportItem = nil
                    case .failure(let error):
                        print(error.localizedDescription)
                        srExportItem = nil
                    }
                } onCancellation: {
                    srExportItem = nil
                }

                Button("Importar Rotina de Estudos") {
                    showSRImportAlert.toggle()
                }
                .alert("Importar Rotina de Estudos?", isPresented: $showSRImportAlert) {
                    Button("Cancelar", role: .cancel) {}
                    Button("Continuar") {
                        showSRFileImporter.toggle()
                    }
                } message: {
                    Text("Ao importar uma nova rotina de estudos, todas os estudos existentes na rotina atual serão apagados. Deseja continuar?")
                }
                .fileImporter(
                    isPresented: $showSRFileImporter,
                    allowedContentTypes: [.data]
                ) { result in
                    switch result {
                    case .success(let url):
                        importedURL = url
                        importSR()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }.listRowBackground(Color.orhadiSecondaryBG)

            Section {
                Button("Apagar todos os estudos") {
                    showDeleteConfirmation.toggle()
                }
                .tint(.red)
                .disabled(studies.isEmpty)
                .alert("Apagar todos os estudos?", isPresented: $showDeleteConfirmation) {
                    Button("Cancelar", role: .cancel) {}
                    Button("Apagar", role: .destructive) {
                        deleteAllStudies()
                    }
                }
            }.listRowBackground(Color.orhadiSecondaryBG)
        }
        .orhadiListStyle()
        .navigationTitle("Rotina de Estudos")
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

    private func deleteAllStudies() {
        Task.detached(priority: .background) {
            do {
                let context = ModelContext(try createContainer())

                let studies = try context.fetch(FetchDescriptor<SRStudy>(predicate: #Predicate<SRStudy> {
                    !$0.isStudyDeleted
                }))

                for study in studies {
                    study.isStudyDeleted = true
                    study.deletedAt = .now
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

    private func exportSR() {
        Task.detached(priority: .background) {
            do {
                let context = ModelContext(try createContainer())

                let descriptor = FetchDescriptor<SRStudy>(predicate: #Predicate<SRStudy> {
                    !$0.isStudyDeleted
                })

                let allObjects = try context.fetch(descriptor)
                let exportItem = SRStudyTransferable(studies: allObjects)

                await UINotificationFeedbackGenerator().notificationOccurred(.success)

                await MainActor.run {
                    self.srExportItem = exportItem
                    self.showSRFileExporter = true
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            }
        }
    }

    private func importSR() {
        guard let url = importedURL else { return }
        Task.detached(priority: .background) {
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            do {
                let context = ModelContext(try createContainer())

                let data = try Data(contentsOf: url)
                let importedStudies = try JSONDecoder().decode(
                    [SRStudy].self, from: data)

                var deletedStudies = try context.fetch(FetchDescriptor<SRStudy>(predicate: #Predicate<SRStudy> {
                    $0.isStudyDeleted
                }))

                let existingStudies = try context.fetch(FetchDescriptor<SRStudy>(predicate: #Predicate<SRStudy> {
                    !$0.isStudyDeleted
                }))

                for study in existingStudies {
                    study.isStudyDeleted = true
                    study.deletedAt = .now

                    deletedStudies.append(study)
                }

                for study in importedStudies {
                    if let matchInTrash = deletedStudies.first(where: {
                        $0.name == study.name &&
                        $0.studyDay == study.studyDay &&
                        $0.studyTime == study.studyTime
                    }) {
                        matchInTrash.isStudyDeleted = false
                        matchInTrash.deletedAt = nil
                    } else {
                        context.insert(study)
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
