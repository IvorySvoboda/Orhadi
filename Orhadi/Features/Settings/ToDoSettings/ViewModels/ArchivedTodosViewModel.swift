//
//  ArchivedTodosViewModel.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 23/10/25.
//

import SwiftUI
import SwiftData
import Observation

extension ArchivedTodosView {
    @Observable class ViewModel {
        var context: ModelContext?
        var archivedToDos: [ToDo] = []
        var selectedToDos = Set<ToDo>()

        func fetchArchivedToDos() {
            guard let context else { return }
            print("Archived To-Dos: fetching...")
            do {
                let descriptor = FetchDescriptor<ToDo>(predicate: #Predicate {
                    $0.isArchived && !$0.isToDoDeleted
                }, sortBy: [.init(\.createdAt)])
                archivedToDos = try context.fetch(descriptor)
            } catch {
                print(error.localizedDescription)
            }
        }

        func deleteToDos() {
            guard let context else { return }
            if selectedToDos.isEmpty {
                for archivedToDo in archivedToDos {
                    try? archivedToDo.softDelete(in: context)
                }
            } else {
                for selectedToDo in selectedToDos {
                    try? selectedToDo.softDelete(in: context)
                }
                selectedToDos.removeAll()

            }
        }

        func unarchiveToDos(scheduleNotifications: Bool = false) {
            guard let context else { return }
            if selectedToDos.isEmpty {
                for archivedToDo in archivedToDos {
                    try? archivedToDo.unarchive(in: context, scheduleNotifications: scheduleNotifications)
                }
            } else {
                for selectedToDo in selectedToDos {
                    try? selectedToDo.unarchive(in: context, scheduleNotifications: scheduleNotifications)
                }
                selectedToDos.removeAll()
            }
        }
    }
}
