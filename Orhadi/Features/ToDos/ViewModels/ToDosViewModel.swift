//
//  ToDosViewModel.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 22/10/25.
//

import SwiftUI
import SwiftData
import Observation

extension ToDosView {
    @Observable class ViewModel {
        var context: ModelContext?
        var pendingToDos: [ToDo] = []
        var completedToDos: [ToDo] = []
        var todoToAdd: ToDo?
        var todoToEdit: ToDo?
        var selectedSection: ToDoSection = .pending
        var showTitle: Bool = false
        var showSelectedSection: Bool = false
        var hideOverlay: Bool = false

        var visibleToDos: [ToDo] {
            selectedSection == .pending ? pendingToDos : completedToDos
        }

        func fetchToDos() {
            guard let context else { return }
            debugPrint("To-Dos: fetching...")
            do {
                let pendingToDosDescriptor = FetchDescriptor<ToDo>(predicate: #Predicate {
                    !$0.isToDoDeleted && !$0.isArchived && !$0.isCompleted
                }, sortBy: [.init(\.dueDate, order: .forward), .init(\.title, order: .forward)])

                let completedToDosDescriptor = FetchDescriptor<ToDo>(predicate: #Predicate {
                    !$0.isToDoDeleted && !$0.isArchived && $0.isCompleted
                }, sortBy: [.init(\.completedAt, order: .reverse)])

                pendingToDos = try context.fetch(pendingToDosDescriptor)
                completedToDos = try context.fetch(completedToDosDescriptor)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }

        func handleScrollGeoChange(_ scrollOffset: CGFloat) {
            debugPrint(scrollOffset)

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

            let shouldHideOverlay = scrollOffset < -300
            if shouldHideOverlay != hideOverlay {
                withAnimation(.smooth(duration: 0.5)) {
                    hideOverlay = shouldHideOverlay
                }
            }
        }
    }
}
