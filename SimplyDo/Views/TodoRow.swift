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
        HStack(spacing: 8) {
            Button(action: toggle) {
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.body)
                    .foregroundStyle(item.isDone ? AppColor.accent : AppColor.textSecondary)
                    .frame(width: Metrics.checkboxTapTarget, height: Metrics.checkboxTapTarget)
            }
            .buttonStyle(.plain)

            if isRenaming {
                TextField("", text: $draft)
                    .textFieldStyle(.plain)
                    .font(.callout)
                    .foregroundStyle(AppColor.textPrimary)
                    .focused($isFieldFocused)
                    .onSubmit(commitRename)
                    .onExitCommand(perform: cancelRename)
            } else {
                Text(item.title)
                    .font(.callout)
                    .strikethrough(item.isDone, color: AppColor.textSecondary)
                    .foregroundStyle(item.isDone ? AppColor.textSecondary : AppColor.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .onTapGesture(count: 2, perform: beginRename)
            }

            Spacer(minLength: 0)

            if isHovering && !isRenaming {
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        store.deleteItem(item.id, in: categoryID)
                    }
                } label: {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }
                .buttonStyle(.plain)
                .help("Delete task")
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .contentShape(.rect)
        .background(RoundedRectangle(cornerRadius: Metrics.rowCornerRadius).fill(isHovering ? AppColor.rowHover : AppColor.row))
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

    return VStack(alignment: .leading, spacing: 8) {
        ForEach(category.items) { item in
            TodoRow(item: item, categoryID: category.id)
        }
    }
    .frame(width: Metrics.popoverWidth)
    .padding(.vertical, 8)
    .environmentObject(store)
}
