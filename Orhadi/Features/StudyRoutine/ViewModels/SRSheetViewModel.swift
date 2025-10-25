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
        var context: ModelContext
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

        init(study: SRStudy, isNew: Bool, context: ModelContext) {
            self.study = study
            self.draftStudy = DraftStudy(from: study)
            self.isNew = isNew
            self.context = context
        }

        func trySave(extraAction: @escaping () -> Void = { return }) {
            if isNew {
                insertNewStudy()
            } else {
                applyStudyChanges()
            }

            do {
                try context.save()
                extraAction()
            } catch {
                print(error.localizedDescription)
            }
        }

        func insertNewStudy() {
            withAnimation {
                context.insert(SRStudy(
                    name: draftStudy.name.trimmingCharacters(in: .whitespaces),
                    studyDay: draftStudy.studyDay,
                    studyTime: draftStudy.studyTime
                ))
            }

            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }

        func applyStudyChanges() {
            study.name = draftStudy.name.trimmingCharacters(in: .whitespaces)
            study.studyDay = draftStudy.studyDay
            study.studyTime = draftStudy.studyTime

            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
    }
}
