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

        var context: ModelContext
        var subject: Subject
        var draftSubject: DraftSubject
        var isNew: Bool
        var showConflictAlert: Bool = false

        // MARK: - Computed Properties

        var navigationTitle: LocalizedStringKey {
            if isNew {
                return subject.isRecess ? "New Interval" : "New Subject"
            } else {
                return subject.isRecess ? "Edit Interval" : "Edit Subject"
            }
        }

        // MARK: - INIT

        init(subject: Subject, isNew: Bool, context: ModelContext) {
            self.context = context
            self.subject = subject
            self.draftSubject = DraftSubject(from: subject)
            self.isNew = isNew
        }

        // MARK: - Functions

        /// `extraAction()` --> An action to be executed if the save succeeds. Can be used to dismiss the view after the save.
        func trySave(extraAction: (() -> Void)? = nil) {
            let hasConflict = SubjectConflictVerifier.hasConflict(
                id: isNew ? nil : subject.id,
                start: draftSubject.startTime,
                end: draftSubject.endTime,
                schedule: draftSubject.schedule,
                context: context
            )

            if hasConflict {
                showConflictAlert.toggle()
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                return
            }

            if isNew {
                insertNewSubject()
            } else {
                applySubjectChanges()
            }

            do {
                try context.save()
                extraAction?()
            } catch {
                print(error.localizedDescription)
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }

        func insertNewSubject() {
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
        }

        func applySubjectChanges() {
            subject.name = draftSubject.name.trimmingCharacters(in: .whitespaces)
            subject.teacher = draftSubject.teacher
            subject.schedule = draftSubject.schedule
            subject.startTime = draftSubject.startTime
            subject.endTime = draftSubject.endTime
            subject.place = draftSubject.place.trimmingCharacters(in: .whitespaces)
        }
    }
}
