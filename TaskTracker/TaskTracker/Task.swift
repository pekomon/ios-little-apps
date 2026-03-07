//
//  Task.swift
//  TaskTracker
//
//  Created by Pekomon on 7.3.2026.
//
	
import Foundation
import SwiftData

@Model
class Task {
    var id = UUID()
    var title: String
    var isCompleted: Bool = false
    
    init(title: String, isCompleted: Bool = false) {
        self.title = title
        self.isCompleted = isCompleted
    }
}

