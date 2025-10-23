//
//  SubjectSheetViewModel.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 22/10/25.
//

import SwiftUI
import SwiftData
import Observation
import WidgetKit

extension SubjectSheetView {
    @Observable class ViewModel {
        var subject: Subject
        var draftSubject: DraftSubject
        var isNew: Bool
        var showAlert: Bool = false

        var navigationTitle: LocalizedStringKey {
            if isNew {
                return subject.isRecess ? "New Interval" : "New Subject"
            } else {
                return subject.isRecess ? "Edit Interval" : "Edit Subject"
            }
        }

        init(subject: Subject, isNew: Bool) {
            self.subject = subject
            self.draftSubject = DraftSubject(from: subject)
            self.isNew = isNew
        }

        func trySave(using context: ModelContext, extraAction: () -> Void = { return }) {
            let hasConflict = SubjectConflictVerifier.hasConflict(
                id: isNew ? nil : subject.id,
                start: draftSubject.startTime,
                end: draftSubject.endTime,
                schedule: draftSubject.schedule,
                context: context
            )

            if hasConflict {
                showAlert.toggle()
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                return
            }

            if isNew {
                insertNewSubject(using: context)
            } else {
                applySubjectChanges()
            }

            WidgetCenter.shared.reloadAllTimelines()
            extraAction()
        }

        private func insertNewSubject(using context: ModelContext) {
            withAnimation {
                context.insert(
                    Subject(
                        name: draftSubject.name.trimmingCharacters(in: .whitespaces),
                        teacher: draftSubject.teacher,
                        schedule: draftSubject.schedule,
                        startTime: draftSubject.startTime,
                        endTime: draftSubject.endTime,
                        place: draftSubject.place.trimmingCharacters(in: .whitespaces),
                        isRecess: draftSubject.isRecess
                    )
                )
            }

            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }

        private func applySubjectChanges() {
            subject.name = draftSubject.name.trimmingCharacters(in: .whitespaces)
            subject.teacher = draftSubject.teacher
            subject.schedule = draftSubject.schedule
            subject.startTime = draftSubject.startTime
            subject.endTime = draftSubject.endTime
            subject.place = draftSubject.place.trimmingCharacters(in: .whitespaces)

            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
    }
}
