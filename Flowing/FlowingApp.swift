//
//  FlowingApp.swift
//  Flowing
//
//  Created by Saúl González on 9/01/24.
//

import SwiftUI
import SwiftData

@main
struct FlowingApp: App {
    var body: some Scene {

        // Show the main view
        WindowGroup {
            MainView()
        }
        .modelContainer(for: [taskItem.self, toDoItem.self, progressiveItem.self, settingsItem.self])  // Load the container items into the view
    }
}
