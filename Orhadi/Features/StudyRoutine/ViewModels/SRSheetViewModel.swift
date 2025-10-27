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

        var context: ModelContext
        var study: SRStudy
        var draftStudy: DraftStudy
        var isNew: Bool

        // MARK: - Computed Properties

        var navigationTitle: LocalizedStringKey {
            if isNew {
                return "New Study"
            } else {
                return "Edit Study"
            }
        }

        // MARK: - INIT

        init(study: SRStudy, isNew: Bool, context: ModelContext) {
            self.study = study
            self.draftStudy = DraftStudy(from: study)
            self.isNew = isNew
            self.context = context
        }

        // MARK: - Functions

        /// `extraAction()` --> An action to be executed if the save succeeds. Can be used to dismiss the view after the save.
        func trySave(extraAction: (() -> Void)?) {
            if isNew {
                insertNewStudy()
            } else {
                applyStudyChanges()
            }

            do {
                try context.save()
                extraAction?()
            } catch {
                print(error.localizedDescription)
            }
        }

        func insertNewStudy() {
            withAnimation {
                context.insert(
                    SRStudy(
                        name: draftStudy.name.trimmingCharacters(in: .whitespaces),
                        studyDay: draftStudy.studyDay,
                        studyTime: draftStudy.studyTime
                    )
                )
            }
        }

        func applyStudyChanges() {
            study.name = draftStudy.name.trimmingCharacters(in: .whitespaces)
            study.studyDay = draftStudy.studyDay
            study.studyTime = draftStudy.studyTime
        }
    }
}
