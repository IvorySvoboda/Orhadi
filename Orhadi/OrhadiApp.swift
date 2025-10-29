//
//  OrhadiApp.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 24/03/25.
//

import SwiftData
import SwiftUI

@main
struct OrhadiApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.modelContainer(DataManager.shared.container)
    }
}
