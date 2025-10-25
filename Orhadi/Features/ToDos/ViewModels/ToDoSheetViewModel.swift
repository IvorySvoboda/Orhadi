//
//  ToDoSheetViewModel.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 22/10/25.
//

import SwiftUI
import SwiftData
import Observation

extension ToDoSheetView {
    @Observable class ViewModel {
        var context: ModelContext
        var todo: ToDo
        var draftToDo: DraftToDo
        var isNew: Bool
        var isHourPickerExpanded = false

        var navigationTitle: LocalizedStringKey {
            if isNew {
                return "New To-Do"
            } else {
                return "Edit To-Do"
            }
        }

        init(todo: ToDo, isNew: Bool, context: ModelContext) {
            self.context = context
            self.todo = todo
            self.draftToDo = DraftToDo(from: todo)
            self.isNew = isNew

        }

        func trySave(scheduleNotifications: Bool = false, extraAction: @escaping () -> Void = { return }) {
            if isNew {
                insertNewToDo(scheduleNotifications: scheduleNotifications)
            } else {
                applyToDoChanges(scheduleNotifications: scheduleNotifications)
            }

            do {
                try context.save()
                extraAction()
            } catch {
                debugPrint(error.localizedDescription)
            }
        }

        func insertNewToDo(scheduleNotifications: Bool = false) {
            let newTodo = ToDo(
                title: draftToDo.title.trimmingCharacters(in: .whitespaces),
                info: draftToDo.info,
                dueDate: draftToDo.dueDate,
                withHour: draftToDo.withHour,
                priority: draftToDo.priority
            )

            if scheduleNotifications {
                newTodo.scheduleNotification()
            }

            if !newTodo.withHour {
                newTodo.dueDate = Calendar.current.startOfDay(for: newTodo.dueDate)
            }

            withAnimation {
                context.insert(newTodo)
            }

            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }

        func applyToDoChanges(scheduleNotifications: Bool = false) {
            todo.title = draftToDo.title.trimmingCharacters(in: .whitespaces)
            todo.info = draftToDo.info
            todo.dueDate = draftToDo.dueDate
            todo.priority = draftToDo.priority
            todo.withHour = draftToDo.withHour

            /// Se não for uma tarefa nova, atualiza as notificações agendadas.
            NotificationsManager.shared.removePendingNotifications(withIdentifiers: todo.identifiers)

            if !todo.withHour {
                todo.dueDate = Calendar.current.startOfDay(for: todo.dueDate)
            }

            /// Sempre respeitando as preferências do usuário.
            if scheduleNotifications {
                todo.scheduleNotification()
            }

            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
    }
}
