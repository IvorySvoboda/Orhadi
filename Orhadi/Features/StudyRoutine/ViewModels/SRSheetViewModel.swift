//
//  SRSheetViewModel.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 22/10/25.
//

import SwiftUI
import SwiftData
import Observation

extension SRSheetView {
    @Observable class ViewModel {
        var study: SRStudy
        var draftStudy: DraftStudy
        var isNew: Bool

        var navigationTitle: LocalizedStringKey {
            if isNew {
                return "New Study"
            } else {
                return "Edit Study"
            }
        }

        init(study: SRStudy, isNew: Bool) {
            self.study = study
            self.draftStudy = DraftStudy(from: study)
            self.isNew = isNew
        }

        func trySave(using context: ModelContext, extraAction: @escaping () -> Void = { return }) {
            if isNew {
                insertNewStudy(using: context)
            } else {
                applyStudyChanges()
            }

            extraAction()
        }

        private func insertNewStudy(using context: ModelContext) {
            withAnimation {
                context.insert(SRStudy(
                    name: draftStudy.name.trimmingCharacters(in: .whitespaces),
                    studyDay: draftStudy.studyDay,
                    studyTime: draftStudy.studyTime
                ))
            }

            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }

        private func applyStudyChanges() {
            study.name = draftStudy.name.trimmingCharacters(in: .whitespaces)
            study.studyDay = draftStudy.studyDay
            study.studyTime = draftStudy.studyTime

            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
    }
}
