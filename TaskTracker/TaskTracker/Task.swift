//
//  Task.swift
//  TaskTracker
//
//  Created by Pekomon on 7.3.2026.
//
	
import Foundation

public struct Task: Identifiable {
    public let id = UUID()
    var title: String
    var isCompleted: Bool = false
}

