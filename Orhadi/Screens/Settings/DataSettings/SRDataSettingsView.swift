//
//  SRDataSettingsView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 23/04/25.
//

import SwiftData
import SwiftUI

struct SRDataSettingsView: View {
    @Environment(OrhadiTheme.self) private var theme

    @Query(animation: .smooth) private var subjects: [SRSubject]

    @State private var showDeleteConfirmation: Bool = false
    /// Exporter
    @State private var srExportItem: SRSubjectTransferable?
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
                    Text("\(self.subjects.count)")
                        .foregroundStyle(.secondary)
                }
            }.listRowBackground(theme.secondaryBGColor())

            Section {
                Button("Exportar Rotina de Estudos") {
                    exportSR()
                }
                .disabled(subjects.isEmpty)
                .fileExporter(
                    isPresented: $showSRFileExporter,
                    item: srExportItem,
                    contentTypes: [.data],
                    defaultFilename: String(localized: "Rotina de Estudos")
                ) { result in
                    switch result {
                    case .success(_):
                        print("Sucesso!")
                    case .failure(let error):
                        print(error.localizedDescription)
                    }

                    srExportItem = nil
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
                    Text("Ao importar uma nova rotina de estudo todas os itens já existentes na rotina atual serão removidas. Deseja continuar?")
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
            }.listRowBackground(theme.secondaryBGColor())

            Section {
                Button("Apagar todos os estudos") {
                    showDeleteConfirmation.toggle()
                }.tint(.red)
                .alert("Apagar todos os estudos?", isPresented: $showDeleteConfirmation) {
                    Button("Cancelar", role: .cancel) {}
                    Button("Apagar", role: .destructive) {
                        deleteAllSRSubjects()
                    }
                }
            }.listRowBackground(theme.secondaryBGColor())
        }
        .modifier(DefaultList())
        .navigationTitle("Rotina de Estudos")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func deleteAllSRSubjects() {
        Task.detached(priority: .background) {
            do {
                let context = try createContext()

                let subjects = try context.fetch(FetchDescriptor<SRSubject>())

                for subject in subjects { context.delete(subject) }

                try context.save()

                await UINotificationFeedbackGenerator().notificationOccurred(.success)
            } catch {
                print(error.localizedDescription)
                await UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }

    private func exportSR() {
        Task.detached(priority: .background) {
            do {
                let context = try createContext()

                let descriptor = FetchDescriptor<SRSubject>()

                let allObjects = try context.fetch(descriptor)
                let exportItem = SRSubjectTransferable(subjects: allObjects)

                await UINotificationFeedbackGenerator().notificationOccurred(.success)

                await MainActor.run {
                    self.srExportItem = exportItem
                    showSRFileExporter = true
                }
            } catch {
                print(error.localizedDescription)
                await UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }

    private func importSR() {
        guard let url = importedURL else { return }
        Task.detached(priority: .background) {
            do {
                guard url.startAccessingSecurityScopedResource() else { return }

                let context = try createContext()

                try context.delete(model: SRSubject.self)

                let data = try Data(contentsOf: url)
                let allSubjects = try JSONDecoder().decode(
                    [SRSubject].self, from: data)

                for subject in allSubjects { context.insert(subject) }

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
