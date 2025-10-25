//
//  DeletedSubjectsViewModel.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 23/10/25.
//

import SwiftUI
import SwiftData
import Observation

extension DeletedSubjectsView {
    @Observable class ViewModel {
        var context: ModelContext?
        var deletedSubjects: [Subject] = []
        var selectedSubjects = Set<Subject>()
        var conflictingSubjects: [Subject] = []
        var showDeleteConfirmation = false
        var showConflictAlert = false

        var countToActOn: Int {
            selectedSubjects.isEmpty ? deletedSubjects.count : selectedSubjects.count
        }

        var isPlural: Bool {
            countToActOn > 1
        }

        var deleteActionTitle: LocalizedStringKey {
            if isPlural {
                return "Delete \(countToActOn) Subjects"
            } else {
                return "Delete Subject"
            }
        }

        var deleteMessageText: LocalizedStringKey {
            if isPlural {
                return "These \(countToActOn) subjects will be deleted. This action cannot be undone."
            } else {
                return "This subject will be deleted. This action cannot be undone."
            }
        }

        var conflictMessageText: LocalizedStringKey {
            if conflictingSubjects.count > 1 {
                return "Some of the subjects are conflicting with existing subjects. Please adjust them before recovering."
            } else {
                return "The selected subject conflicts with an existing subject. Please adjust it before recovering."
            }
        }

        func fetchDeletedSubjects() {
            guard let context else { return }
            print("Deleted Subjects: fetching...")
            do {
                let descriptor = FetchDescriptor<Subject>(predicate: #Predicate {
                    $0.isSubjectDeleted
                }, sortBy: [.init(\.deletedAt)])
                deletedSubjects = try context.fetch(descriptor)
            } catch {
                print(error.localizedDescription)
            }
        }

        // MARK: Delete Actions

        func deleteSubjects() {
            guard let context else { return }

            if selectedSubjects.isEmpty {
                for subject in deletedSubjects {
                    try? subject.hardDelete(in: context)
                }
            } else {
                for subject in selectedSubjects {
                    try? subject.hardDelete(in: context)
                }
                selectedSubjects.removeAll()
            }
        }

        // MARK: Restore Actions

        func restoreSubjects() {
            guard let context else { return }

            if selectedSubjects.isEmpty {
                for subject in deletedSubjects {
                    let hasConflictWithOthersSubjects = SubjectConflictVerifier.hasConflictWithOtherSubjects(
                        id: subject.id,
                        start: subject.startTime,
                        end: subject.endTime,
                        schedule: subject.schedule,
                        context: context
                    )

                    if hasConflictWithOthersSubjects {
                        conflictingSubjects.append(subject)
                    } else {
                        try? subject.restore(in: context)
                    }
                }

                if !conflictingSubjects.isEmpty {
                    showConflictAlert.toggle()
                }
            } else {
                for subject in selectedSubjects {
                    let hasConflictWithOthersSubjects = SubjectConflictVerifier.hasConflictWithOtherSubjects(
                        id: subject.id,
                        start: subject.startTime,
                        end: subject.endTime,
                        schedule: subject.schedule,
                        context: context
                    )

                    if hasConflictWithOthersSubjects {
                        conflictingSubjects.append(subject)
                    } else {
                        try? subject.restore(in: context)
                    }
                }

                selectedSubjects.removeAll()

                if !conflictingSubjects.isEmpty {
                    showConflictAlert.toggle()
                }
            }
        }
    }
}
