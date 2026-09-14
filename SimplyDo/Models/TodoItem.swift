//
//  TodoItem.swift
//  SimplyDo
//
//  Created by Oleksandr
//

import Foundation

struct TodoItem: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var isDone: Bool = false
    var createdAt: Date = .now
    var completedAt: Date?
}
