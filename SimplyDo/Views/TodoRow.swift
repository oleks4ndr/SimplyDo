//
//  TodoRow.swift
//  SimplyDo
//
//  Created by Oleksandr
//

import SwiftUI

struct TodoRow: View {
    @EnvironmentObject private var store: TodoStore

    let item: TodoItem
    let categoryID: TodoCategory.ID

    @State private var isHovering = false
    @State private var isRenaming = false
    @State private var draft = ""
    @FocusState private var isFieldFocused: Bool

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Button(action: toggle) {
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.body)
                    .foregroundStyle(item.isDone ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
            }
            .buttonStyle(.plain)

            if isRenaming {
                TextField("", text: $draft)
                    .textFieldStyle(.plain)
                    .font(.callout)
                    .focused($isFieldFocused)
                    .onSubmit(commitRename)
                    .onExitCommand(perform: cancelRename)
            } else {
                Text(item.title)
                    .font(.callout)
                    .strikethrough(item.isDone, color: .secondary)
                    .foregroundStyle(item.isDone ? .secondary : .primary)
                    .lineLimit(2)
                    .onTapGesture(count: 2, perform: beginRename)
            }

            Spacer(minLength: 0)

            if isHovering && !isRenaming {
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        store.deleteItem(item.id, in: categoryID)
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
                .help("Delete task")
            }
        }
        .padding(.leading, 18)
        .padding(.trailing, 6)
        .padding(.vertical, 4)
        .contentShape(.rect)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(isHovering ? Color.primary.opacity(0.06) : .clear)
        )
        .padding(.horizontal, 6)
        .onHover { isHovering = $0 }
        .contextMenu {
            Button("Rename", action: beginRename)
            Button("Delete", role: .destructive) {
                store.deleteItem(item.id, in: categoryID)
            }
        }
    }

    private func toggle() {
        withAnimation(.easeInOut(duration: 0.15)) {
            store.toggleDone(item.id, in: categoryID)
        }
    }

    private func beginRename() {
        draft = item.title
        isRenaming = true
        isFieldFocused = true
    }

    private func commitRename() {
        store.renameItem(item.id, in: categoryID, to: draft)
        isRenaming = false
    }

    private func cancelRename() {
        isRenaming = false
    }
}

#Preview {
    let store = TodoStore.preview
    let category = store.categories[0]

    return VStack(alignment: .leading, spacing: 0) {
        ForEach(category.items) { item in
            TodoRow(item: item, categoryID: category.id)
        }
    }
    .frame(width: 320)
    .padding(.vertical, 8)
    .environmentObject(store)
}
