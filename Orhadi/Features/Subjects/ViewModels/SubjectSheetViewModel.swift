//
//  SubjectSheetViewModel.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 22/10/25.
//

import SwiftUI
import SwiftData
import Observation

extension SubjectSheetView {
    @Observable class ViewModel {
        // MARK: - Properties

        private let dataManager: DataManager
        let subject: Subject
        let isNew: Bool
        var draftSubject: DraftSubject
        var showErrorAlert = false
        var errorAlertMessage = ""

        // MARK: - Computed Properties

        var navigationTitle: LocalizedStringKey {
            if isNew {
                return subject.isRecess ? "New Interval" : "New Subject"
            } else {
                return subject.isRecess ? "Edit Interval" : "Edit Subject"
            }
        }

        var canSave: Bool {
            draftSubject.name.isEmpty &&
            !draftSubject.isRecess ||
            !dataManager.isSubjectScheduleInvalid(isNew ? Subject(from: draftSubject) : subject)
        }

        // MARK: - INIT

        init(subject: Subject, isNew: Bool, dataManager: DataManager) {
            self.dataManager = dataManager
            self.subject = subject
            self.draftSubject = DraftSubject(from: subject)
            self.isNew = isNew
        }

        // MARK: - Functions

        /// `extraAction()` --> An action to be executed if the save succeeds. Can be used to dismiss the view after the save.
        func trySave(extraAction: (() -> Void)? = nil) throws {
            do {
                if isNew {
                    try dataManager.addSubject(Subject(from: draftSubject))
                } else {
                    try dataManager.editSubject(subject, with: draftSubject)
                }

                extraAction?()
            } catch {
                errorAlertMessage = error.localizedDescription
                showErrorAlert = true
                throw error /// Useful for unit tests.
            }
        }
    }
}
