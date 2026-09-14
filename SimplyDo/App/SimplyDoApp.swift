//
//  SimplyDoApp.swift
//  SimplyDo
//
//  Created by Oleksandr on 09/02/2026.
//

import SwiftUI

@main
struct SimplyDoApp: App {
    // LSUIElement is YES in build settings, so there's no dock icon and no main window
    @StateObject private var store = TodoStore()

    var body: some Scene {
        MenuBarExtra("SimplyDo", systemImage: "checklist") {
            MenuContentView()
                .environmentObject(store)
        }
        .menuBarExtraStyle(.window)
    }
}
