//
//  SRDataSettingsViewModel.swift
//  Orhadi
//
//  Created by Zyvoxi . on 28/04/25.
//

import SwiftUI
import SwiftData
import Observation

@Observable class SRDataSettingsViewModel {
    // MARK: - Properties

    var showDeleteConfirmation: Bool = false

    /// Exporter
    var srExportItem: SRStudyTransferable?
    var showSRFileExporter: Bool = false

    /// Importer
    var showSRImportAlert: Bool = false
    var showSRFileImporter: Bool = false
    var importedURL: URL?

    // MARK: - Computed Properties

    var studies: [SRStudy]? {
        let context = try! createContext()
        return try? context.fetch(FetchDescriptor<SRStudy>())
    }

    // MARK: - Actions

    func deleteAllStudies() {
        Task.detached(priority: .background) {
            do {
                let context = try createContext()

                let studies = try context.fetch(FetchDescriptor<SRStudy>())

                for study in studies { context.delete(study) }

                try context.save()

                await UINotificationFeedbackGenerator().notificationOccurred(.success)
            } catch {
                print(error.localizedDescription)
                await UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }

    func exportSR() {
        Task.detached(priority: .background) {
            do {
                let context = try createContext()

                let descriptor = FetchDescriptor<SRStudy>()

                let allObjects = try context.fetch(descriptor)
                let exportItem = SRStudyTransferable(studies: allObjects)

                await UINotificationFeedbackGenerator().notificationOccurred(.success)

                await MainActor.run {
                    self.srExportItem = exportItem
                    self.showSRFileExporter = true
                }
            } catch {
                print(error.localizedDescription)
                await UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }

    func importSR() {
        guard let url = importedURL else { return }
        Task.detached(priority: .background) {
            do {
                guard url.startAccessingSecurityScopedResource() else { return }

                let context = try createContext()

                try context.delete(model: SRStudy.self)

                let data = try Data(contentsOf: url)
                let allStudies = try JSONDecoder().decode(
                    [SRStudy].self, from: data)

                for study in allStudies { context.insert(study) }

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
