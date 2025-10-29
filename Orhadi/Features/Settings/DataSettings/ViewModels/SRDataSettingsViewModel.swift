//
//  SRDataSettingsViewModel.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 23/10/25.
//

import SwiftUI
import SwiftData
import Observation
import Combine

extension SRDataSettingsView {
    @Observable class ViewModel {
        // MARK: - Properties

        private let dataManager: DataManager
        private var cancellable: AnyCancellable?
        var studies: [SRStudy] = []
        var showDeleteConfirmation: Bool = false
        var showErrorMessage: Bool = false
        var errorMessage: String = ""
        /// Exporter
        var srExportItem: DataTransferable?
        var showSRFileExporter: Bool = false
        /// Importer
        var showSRImportAlert: Bool = false
        var showSRFileImporter: Bool = false
        var importedURL: URL?

        // MARK: - INIT

        init(dataManager: DataManager) {
            self.dataManager = dataManager
            setup()
        }

        // MARK: - Functions

        private func setup() {
            cancellable = dataManager.observeContextChanges(of: SRStudy.self) { [weak self] in
                self?.updateStudies()
            }
            updateStudies()
        }

        private func updateStudies() {
            studies = dataManager.fetchStudies(
                predicate: #Predicate { !$0.isStudyDeleted }
            )
        }

        func deleteAllStudies() throws {
            do {
                let context = ModelContext(dataManager.container)

                let studies = try context.fetch(FetchDescriptor<SRStudy>(predicate: #Predicate<SRStudy> {
                    !$0.isStudyDeleted
                }))

                for study in studies {
                    study.isStudyDeleted = true
                    study.deletedAt = .now
                }

                try context.save()

                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } catch {
                errorMessage = error.localizedDescription
                showErrorMessage.toggle()
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                throw error /// Useful for unit tests.
            }
        }

        func exportSR() throws {
            do {
                let context = ModelContext(dataManager.container)

                let descriptor = FetchDescriptor<SRStudy>(predicate: #Predicate<SRStudy> {
                    !$0.isStudyDeleted
                })

                let allObjects = try context.fetch(descriptor)
                let data = try JSONEncoder().encode(allObjects)
                let exportItem = DataTransferable(data: data)

                srExportItem = exportItem
                showSRFileExporter = true

                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } catch {
                errorMessage = error.localizedDescription
                showErrorMessage.toggle()
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                throw error /// Useful for unit tests.
            }
        }

        func importSR() throws {
            guard let url = importedURL else { return }
            let isInBundle = url.path.contains(Bundle.main.bundlePath)
            guard url.startAccessingSecurityScopedResource() || isInBundle else { return }
            defer { if !isInBundle { url.stopAccessingSecurityScopedResource() } }
            do {
                let context = ModelContext(dataManager.container)

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

                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } catch {
                errorMessage = error.localizedDescription
                showErrorMessage.toggle()
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                throw error /// Useful for unit tests.
            }
        }
    }
}
