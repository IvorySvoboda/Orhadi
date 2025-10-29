//
//  ToDosViewModel.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 22/10/25.
//

import Observation
import SwiftData
import SwiftUI
import Combine

extension ToDosView {
    @Observable class ViewModel {
        // MARK: - Properties

        private let dataManager: DataManager
        private var cancellable: AnyCancellable?
        var pendingToDos: [ToDo] = []
        var completedToDos: [ToDo] = []
        var todoToAdd: ToDo?
        var todoToEdit: ToDo?
        var selectedSection: ToDoSection = .pending
        var showTitle: Bool = false
        var showSelectedSection: Bool = false
        var hideOverlay: Bool = false

        // MARK: - Computed Properties

        var visibleToDos: [ToDo] {
            selectedSection == .pending ? pendingToDos : completedToDos
        }

        // MARK: INIT

        init(dataManager: DataManager) {
            self.dataManager = dataManager
            setup()
        }

        // MARK: - Functions

        private func setup() {
            cancellable = dataManager.observeContextChanges(of: ToDo.self) { [weak self] in
                self?.updateToDos()
            }
            updateToDos()
        }

        private func updateToDos() {
            pendingToDos = dataManager.fetchToDos(
                predicate: #Predicate {
                    !$0.isToDoDeleted && !$0.isArchived && !$0.isCompleted
                },
                sortBy: [
                    .init(\.dueDate, order: .forward),
                    .init(\.title, order: .forward)
                ]
            )

            completedToDos = dataManager.fetchToDos(
                predicate: #Predicate {
                    !$0.isToDoDeleted && !$0.isArchived && $0.isCompleted
                },
                sortBy: [
                    .init(\.completedAt, order: .reverse)
                ]
            )
        }

        func toggleToDoCompleted(_ todo: ToDo) throws {
            try dataManager.toggleToDoCompleted(todo)
        }

        func archiveToDo(_ todo: ToDo) throws {
            try dataManager.archive(todo)
        }

        func softDeleteToDo(_ todo: ToDo) throws {
            try dataManager.softDelete(todo)
        }

        func handleScrollGeoChange(_ scrollOffset: CGFloat) {
            let shouldShowTitle = scrollOffset >= -101
            if shouldShowTitle != showTitle {
                withAnimation(.smooth(duration: 0.5)) {
                    showTitle = shouldShowTitle
                }
            }

            let shouldShowWeekday = scrollOffset >= -56
            if shouldShowWeekday != showSelectedSection {
                withAnimation(.smooth(duration: 0.5)) {
                    showSelectedSection = shouldShowWeekday
                }
            }

            let shouldHideOverlay = scrollOffset <= -300
            if shouldHideOverlay != hideOverlay {
                withAnimation(.smooth(duration: 0.5)) {
                    hideOverlay = shouldHideOverlay
                }
            }
        }
    }
}
