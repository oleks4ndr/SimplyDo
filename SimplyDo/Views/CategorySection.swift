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

    @State private var isAddingTask = false
    @State private var newTaskDraft = ""
    @FocusState private var isTaskFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.cardContentSpacing) {
            header

            if isAddingTask {
                addTaskField
            }

            if !category.isCollapsed && !category.items.isEmpty {
                ForEach(category.items) { item in
                    TodoRow(item: item, categoryID: category.id)
                }
            }
        }
        .padding(Metrics.cardPadding)
        .background(RoundedRectangle(cornerRadius: Metrics.cardCornerRadius))
        .onChange(of: category.isCollapsed) { _, isCollapsed in
            if isCollapsed { isAddingTask = false }
        }
        .onChange(of: isTaskFieldFocused) { _, isFocused in
            if !isFocused { isAddingTask = false }
        }
    }

    private var header: some View {
        HStack(spacing: 6) {
            Image(systemName: "chevron.right")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(AppColor.textSecondary)
                .rotationEffect(.degrees(category.isCollapsed ? 0 : 90))
                .opacity(isHovering && !category.items.isEmpty ? 1 : 0)

            if isRenaming {
                TextField("", text: $draft)
                    .textFieldStyle(.plain)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColor.textPrimary)
                    .focused($isFieldFocused)
                    .onSubmit(commitRename)
                    .onExitCommand { isRenaming = false }
            } else {
                Text(category.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColor.textPrimary)
                    .onTapGesture(count: 2, perform: beginRename)
            }

            Spacer(minLength: 0)

            Text("\(category.items.count) task\(category.items.count == 1 ? "" : "s")")
                .font(.caption)
                .monospacedDigit()
                .foregroundStyle(AppColor.textSecondary)

            Button(action: toggleAddingTask) {
                Image(systemName: "plus")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(AppColor.textPrimary)
                    .frame(width: Metrics.checkboxTapTarget, height: Metrics.checkboxTapTarget)
                    .background(Circle().fill(AppColor.row))
            }
            .buttonStyle(.plain)
            .help("Add task")
        }
        .contentShape(.rect)
        .onHover { isHovering = $0 }
        .onTapGesture {
            guard !isRenaming, !category.items.isEmpty else { return }
            withAnimation(.easeInOut(duration: 0.18)) {
                store.toggleCollapsed(category.id)
            }
        }
        .contextMenu {
            Button("Rename", action: beginRename)
            Button("Delete", role: .destructive, action: confirmDelete)
        }
    }

    private var addTaskField: some View {
        HStack(spacing: 8) {
            Image(systemName: "plus")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppColor.textSecondary)

            TextField("Add task", text: $newTaskDraft)
                .textFieldStyle(.plain)
                .font(.callout)
                .foregroundStyle(AppColor.textPrimary)
                .focused($isTaskFieldFocused)
                .onSubmit(commitNewTask)
                .onExitCommand { isAddingTask = false }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: Metrics.rowCornerRadius).fill(AppColor.row))
    }

    private func toggleAddingTask() {
        if isAddingTask {
            isAddingTask = false
        } else {
            newTaskDraft = ""
            isAddingTask = true
            isTaskFieldFocused = true
        }
    }

    private func commitNewTask() {
        store.addItem(title: newTaskDraft, to: category.id)
        newTaskDraft = ""
        isTaskFieldFocused = true
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

    return VStack(alignment: .leading, spacing: Metrics.cardSpacing) {
        ForEach(store.categories) { category in
            CategorySection(category: category)
        }
    }
    .frame(width: Metrics.popoverWidth)
    .padding(.vertical, 8)
    .environmentObject(store)
}
