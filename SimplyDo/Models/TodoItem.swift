//
//  TodoItem.swift
//  SimplyDo
//
//  Created by Oleksandr
//

import Foundation

// named TodoItem, not Task, so it doesn't collide with concurrency's Task
struct TodoItem: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var isDone: Bool = false
    var createdAt: Date = .now
    var completedAt: Date?
}
