//
//  TodoCategory.swift
//  SimplyDo
//
//  Created by Oleksandr
//

import Foundation

struct TodoCategory: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var isCollapsed: Bool = false
    var items: [TodoItem] = []

    var completedCount: Int {
        items.filter(\.isDone).count
    }
}
