//
//  ToDosViewModel.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 22/10/25.
//

import SwiftUI
import Observation

extension ToDosView {
    @Observable class ViewModel {
        var todoToAdd: ToDo?
        var todoToEdit: ToDo?
        var selectedSection: ToDoSection = .pending
        var showTitle: Bool = false
        var showSelectedSection: Bool = false
        var hideOverlay: Bool = false

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
