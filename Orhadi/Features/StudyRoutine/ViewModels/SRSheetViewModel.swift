//
//  SRSheetViewModel.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 22/10/25.
//

import Observation
import SwiftData
import SwiftUI

extension SRSheetView {
    @Observable class ViewModel {
        // MARK: - Properties

        private let dataManager: DataManager
        let study: SRStudy
        let isNew: Bool
        var draftStudy: DraftStudy
        var showErrorAlert = false
        var errorAlertMessage = ""

        // MARK: - Computed Properties

        var navigationTitle: LocalizedStringKey {
            if isNew {
                return "New Study"
            } else {
                return "Edit Study"
            }
        }

        // MARK: - INIT

        init(study: SRStudy, isNew: Bool, dataManager: DataManager) {
            self.study = study
            self.draftStudy = DraftStudy(from: study)
            self.isNew = isNew
            self.dataManager = dataManager
        }

        // MARK: - Functions

        /// `extraAction()` --> An action to be executed if the save succeeds. Can be used to dismiss the view after the save.
        func trySave(extraAction: (() -> Void)? = nil) throws {
            do {
                if isNew {
                    try dataManager.addStudy(SRStudy(from: draftStudy))
                } else {
                    try dataManager.editStudy(study, with: draftStudy)
                }

                extraAction?()
            } catch {
                errorAlertMessage = error.localizedDescription
                showErrorAlert = true
                throw error
            }
        }
    }
}
