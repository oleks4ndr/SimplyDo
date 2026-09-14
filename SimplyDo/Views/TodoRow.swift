//
//  TodoRow.swift
//  SimplyDo
//
//  Created by Oleksandr
//

import SwiftUI

struct TodoRow: View {
    let item: TodoItem

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                .font(.body)
                .foregroundStyle(item.isDone ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))

            Text(item.title)
                .font(.callout)
                .strikethrough(item.isDone, color: .secondary)
                .foregroundStyle(item.isDone ? .secondary : .primary)
                .lineLimit(2)

            Spacer(minLength: 0)
        }
        .padding(.leading, 24)
        .padding(.trailing, 12)
        .padding(.vertical, 3)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 0) {
        TodoRow(item: TodoItem(title: "Ship the PR"))
        TodoRow(item: TodoItem(title: "Standup notes", isDone: true, completedAt: .now))
        TodoRow(item: TodoItem(title: "A much longer task title that has to wrap onto a second line"))
    }
    .frame(width: 320)
    .padding(.vertical, 8)
}
