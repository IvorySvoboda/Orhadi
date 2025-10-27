//
//  DeletedTodosViewModel.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 23/10/25.
//

import SwiftUI
import SwiftData
import Observation

extension DeletedTodosView {
    @Observable class ViewModel {
        var context: ModelContext?
        var deletedToDos: [ToDo] = []
        var selectedToDos = Set<ToDo>()
        var showDeleteConfirmation = false

        var countToActOn: Int {
            selectedToDos.isEmpty ? deletedToDos.count : selectedToDos.count
        }

        var isPlural: Bool {
            countToActOn > 1
        }

        var deleteActionTitle: LocalizedStringKey {
            if isPlural {
                return "Delete \(countToActOn) To-Dos"
            } else {
                return "Delete To-Do"
            }
        }

        var deleteMessageText: LocalizedStringKey {
            if isPlural {
                return "These \(countToActOn) to-dos will be deleted. This action cannot be undone."
            } else {
                return "This to-do will be deleted. This action cannot be undone."
            }
        }

        func fetchDeletedToDos() {
            guard let context else { return }
            do {
                let descriptor = FetchDescriptor<ToDo>(predicate: #Predicate {
                    $0.isToDoDeleted
                }, sortBy: [.init(\.deletedAt)])
                deletedToDos = try context.fetch(descriptor)
            } catch {
                print(error.localizedDescription)
            }
        }

        func deleteToDos() {
            guard let context else { return }

            if selectedToDos.isEmpty {
                for todo in deletedToDos {
                    try? todo.hardDelete(in: context)
                }
            } else {
                for todo in selectedToDos {
                    try? todo.hardDelete(in: context)
                }
                selectedToDos.removeAll()
            }
        }

        func restoreToDos(scheduleNotifications: Bool = false) {
            guard let context else { return }
            if selectedToDos.isEmpty {
                for todo in deletedToDos {
                    try? todo.restore(in: context, scheduleNotifications: scheduleNotifications)
                }
            } else {
                for todo in selectedToDos {
                    try? todo.restore(in: context, scheduleNotifications: scheduleNotifications)
                }
                selectedToDos.removeAll()
            }
        }
    }
}
