//
//  CategorySection.swift
//  SimplyDo
//
//  Created by Oleksandr
//

import SwiftUI

struct CategorySection: View {
    let category: TodoCategory

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            if !category.isCollapsed {
                if category.items.isEmpty {
                    Text("Nothing here yet")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .padding(.leading, 24)
                        .padding(.vertical, 3)
                } else {
                    ForEach(category.items) { item in
                        TodoRow(item: item)
                    }
                }
            }
        }
        .padding(.bottom, 6)
    }

    private var header: some View {
        HStack(spacing: 6) {
            Image(systemName: "chevron.right")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
                .rotationEffect(.degrees(category.isCollapsed ? 0 : 90))

            Text(category.name)
                .font(.subheadline.weight(.semibold))

            Spacer(minLength: 0)

            Text("\(category.completedCount)/\(category.items.count)")
                .font(.caption)
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 0) {
        CategorySection(category: TodoCategory(name: "Work", items: [
            TodoItem(title: "Ship the PR"),
            TodoItem(title: "Standup notes", isDone: true, completedAt: .now)
        ]))
        CategorySection(category: TodoCategory(name: "Someday", isCollapsed: true, items: [
            TodoItem(title: "Learn Metal")
        ]))
        CategorySection(category: TodoCategory(name: "Empty"))
    }
    .frame(width: 320)
    .padding(.vertical, 8)
}
