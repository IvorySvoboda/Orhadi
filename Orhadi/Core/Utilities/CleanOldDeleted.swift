//
//  CleanOldDeleted.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 06/08/25.
//

import Foundation
import SwiftData

func cleanOldDeleted() {
    Task.detached(priority: .background) {
        do {
            let context = ModelContext(createContainer())

            let deletedSubjects = try context.fetch(FetchDescriptor<Subject>(predicate: #Predicate<Subject> {
                $0.isSubjectDeleted
            }))
            let deletedToDos = try context.fetch(FetchDescriptor<ToDo>(predicate: #Predicate<ToDo> {
                $0.isToDoDeleted
            }))
            let deletedStudies = try context.fetch(FetchDescriptor<SRStudy>(predicate: #Predicate<SRStudy> {
                $0.isStudyDeleted
            }))

            for deletedSubject in deletedSubjects where deletedSubject.deletedAt?.addingTimeInterval(2_592_000) ?? .now.addingTimeInterval(-2_678_400) < .now {
                context.delete(deletedSubject)
            }

            for deletedToDo in deletedToDos where deletedToDo.deletedAt?.addingTimeInterval(2_592_000) ?? .now.addingTimeInterval(-2_678_400) < .now {
                context.delete(deletedToDo)
            }

            for deletedStudy in deletedStudies where deletedStudy.deletedAt?.addingTimeInterval(2_592_000) ?? .now.addingTimeInterval(-2_678_400) < .now {
                context.delete(deletedStudy)
            }

            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}
