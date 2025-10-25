//
//  DeletedStudyViewModel.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 23/10/25.
//

import SwiftUI
import SwiftData
import Observation

extension DeletedStudiesView {
    @Observable class ViewModel {
        var context: ModelContext?
        var deletedStudies: [SRStudy] = []
        var selectedStudies = Set<SRStudy>()
        var showDeleteConfirmation = false

        var countToActOn: Int {
            selectedStudies.isEmpty ? deletedStudies.count : selectedStudies.count
        }

        var isPlural: Bool {
            countToActOn > 1
        }

        var deleteActionTitle: LocalizedStringKey {
            if isPlural {
                return "Delete \(countToActOn) Studies"
            } else {
                return "Delete Study"
            }
        }

        var deleteMessageText: LocalizedStringKey {
            if isPlural {
                return "These \(countToActOn) studies will be deleted. This action cannot be undone."
            } else {
                return "This study will be deleted. This action cannot be undone."
            }
        }

        func fetchDeletedStudies() {
            guard let context else { return }
            debugPrint("Deleted Studies: fetching...")
            do {
                let descriptor = FetchDescriptor<SRStudy>(predicate: #Predicate {
                    $0.isStudyDeleted
                }, sortBy: [.init(\.deletedAt)])
                deletedStudies = try context.fetch(descriptor)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }

        func deleteStudies() {
            guard let context else { return }
            if selectedStudies.isEmpty {
                for study in deletedStudies {
                    try? study.hardDelete(in: context)
                }
            } else {
                for study in selectedStudies {
                    try? study.hardDelete(in: context)
                }
                selectedStudies.removeAll()
            }
        }

        func restoreStudies() {
            guard let context else { return }
            if selectedStudies.isEmpty {
                for study in deletedStudies {
                    try? study.restore(in: context)
                }
            } else {
                for study in selectedStudies {
                    try? study.restore(in: context)
                }
                selectedStudies.removeAll()
            }
        }
    }
}
