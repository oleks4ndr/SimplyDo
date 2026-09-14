//
//  CategorySection.swift
//  SimplyDo
//
//  Created by Oleksandr
//

import AppKit
import SwiftUI

struct CategorySection: View {
    @EnvironmentObject private var store: TodoStore

    let category: TodoCategory

    @State private var isHovering = false
    @State private var isRenaming = false
    @State private var draft = ""
    @FocusState private var isFieldFocused: Bool

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
                        TodoRow(item: item, categoryID: category.id)
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

            if isRenaming {
                TextField("", text: $draft)
                    .textFieldStyle(.plain)
                    .font(.subheadline.weight(.semibold))
                    .focused($isFieldFocused)
                    .onSubmit(commitRename)
                    .onExitCommand { isRenaming = false }
            } else {
                Text(category.name)
                    .font(.subheadline.weight(.semibold))
                    .onTapGesture(count: 2, perform: beginRename)
            }

            Spacer(minLength: 0)

            Text("\(category.completedCount)/\(category.items.count)")
                .font(.caption)
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .contentShape(.rect)
        .background(isHovering && !isRenaming ? Color.primary.opacity(0.04) : .clear)
        .onHover { isHovering = $0 }
        .onTapGesture {
            guard !isRenaming else { return }
            withAnimation(.easeInOut(duration: 0.18)) {
                store.toggleCollapsed(category.id)
            }
        }
        .contextMenu {
            Button("Rename", action: beginRename)
            Button("Delete", role: .destructive, action: confirmDelete)
        }
    }

    private func beginRename() {
        draft = category.name
        isRenaming = true
        isFieldFocused = true
    }

    private func commitRename() {
        store.renameCategory(category.id, to: draft)
        isRenaming = false
    }
    
    private func confirmDelete() {
        guard !category.items.isEmpty else {
            store.deleteCategory(category.id)
            return
        }

        let count = category.items.count
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Delete “\(category.name)”?"
        alert.informativeText = "Its \(count) task\(count == 1 ? "" : "s") will be deleted too."
        alert.addButton(withTitle: "Delete")
        alert.addButton(withTitle: "Cancel")

        NSApp.activate(ignoringOtherApps: true)
        if alert.runModal() == .alertFirstButtonReturn {
            store.deleteCategory(category.id)
        }
    }
}

#Preview {
    let store = TodoStore.preview

    return VStack(alignment: .leading, spacing: 0) {
        ForEach(store.categories) { category in
            CategorySection(category: category)
        }
    }
    .frame(width: 320)
    .padding(.vertical, 8)
    .environmentObject(store)
}
