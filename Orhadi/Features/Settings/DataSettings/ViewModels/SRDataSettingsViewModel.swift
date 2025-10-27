//
//  SRDataSettingsViewModel.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 23/10/25.
//

import UIKit
import SwiftData
import Observation

extension SRDataSettingsView {
    @Observable class ViewModel {
        var container: ModelContainer
        var context: ModelContext?
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

        init(container: ModelContainer = createContainer()) {
            self.container = container
        }

        func fetchStudies() {
            guard let context else { return }
            do {
                let descriptor = FetchDescriptor<SRStudy>(predicate: #Predicate { !$0.isStudyDeleted })
                studies = try context.fetch(descriptor)
            } catch {
                print(error.localizedDescription)
            }
        }

        func deleteAllStudies() throws {
            do {
                let context = ModelContext(container)

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
                throw error
            }
        }

        func exportSR() throws {
            do {
                let context = ModelContext(container)

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
                throw error
            }
        }

        func importSR() throws {
            guard let url = importedURL else { return }
            let isInBundle = url.path.contains(Bundle.main.bundlePath)
            guard url.startAccessingSecurityScopedResource() || isInBundle else { return }
            defer { if !isInBundle { url.stopAccessingSecurityScopedResource() } }
            do {
                let context = ModelContext(container)

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
                throw error
            }
        }
    }
}
