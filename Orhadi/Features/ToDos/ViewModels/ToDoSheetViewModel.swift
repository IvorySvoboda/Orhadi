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
        // MARK: - Properties

        private let dataManager: DataManager
        let todo: ToDo
        let isNew: Bool
        var draftToDo: DraftToDo {
            didSet {
                if draftToDo.withHour {
                    isHourPickerExpanded = true
                } else {
                    isHourPickerExpanded = false
                }
            }
        }
        var isHourPickerExpanded = false
        var showErrorAlert = false
        var errorAlertMessage = ""

        // MARK: Computed Properties

        var navigationTitle: LocalizedStringKey {
            if isNew {
                return "New To-Do"
            } else {
                return "Edit To-Do"
            }
        }

        var isTimePickerExpanded: Binding<Bool> {
            Binding(
                get: { self.isHourPickerExpanded && self.draftToDo.withHour },
                set: { self.isHourPickerExpanded = self.draftToDo.withHour ? $0 : false }
            )
        }

        // MARK: - INIT

        init(todo: ToDo, isNew: Bool, dataManager: DataManager) {
            self.dataManager = dataManager
            self.todo = todo
            self.draftToDo = DraftToDo(from: todo)
            self.isNew = isNew
        }

        // MARK: - Functions

        /// `extraAction()` --> An action to be executed if the save succeeds. Can be used to dismiss the view after the save.
        func trySave(extraAction: (() -> Void)? = nil) throws {
            do {
                if isNew {
                    try dataManager.addToDo(ToDo(from: draftToDo))
                } else {
                    try dataManager.editToDo(todo, with: draftToDo)
                }

                extraAction?()
            } catch {
                errorAlertMessage = error.localizedDescription
                showErrorAlert = true
                throw error /// Useful for unit tests.
            }
        }
    }
}
