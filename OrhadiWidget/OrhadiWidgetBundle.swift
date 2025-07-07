//
//  OrhadiWidgetBundle.swift
//  OrhadiWidget
//
//  Created by Zyvoxi . on 06/07/25.
//

import WidgetKit
import SwiftUI

@main
struct OrhadiWidgetBundle: WidgetBundle {
    var body: some Widget {
        SubjectsScheduleWidget()
        PendingTodosWidget()
    }
}
