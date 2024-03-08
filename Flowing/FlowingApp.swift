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
        WindowGroup {
            MainView()
        }
        
        .modelContainer(for: taskItem.self)
    }
    
    
}

