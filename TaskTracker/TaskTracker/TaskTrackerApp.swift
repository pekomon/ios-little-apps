//
//  TaskTrackerApp.swift
//  TaskTracker
//
//  Created by Pekomon on 7.3.2026.
//

import SwiftUI
import SwiftData

@main
struct TaskTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Task.self)
    }
}
