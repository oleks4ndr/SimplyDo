//
//  MenuContentView.swift
//  SimplyDo
//
//  Created by Oleksandr
//

import SwiftUI

struct MenuContentView: View {
    @EnvironmentObject private var store: TodoStore

    @AppStorage("lastUsedCategoryID") private var lastUsedCategoryID = ""

    @State private var isAddingCategory = false
    @State private var newCategoryName = ""
    @FocusState private var isCategoryFieldFocused: Bool

    @State private var contentHeight: CGFloat = 0

    private static let maxListHeight: CGFloat = 420

    private var openCount: Int {
        store.categories.reduce(0) { $0 + ($1.items.count - $1.completedCount) }
    }

    private var targetCategory: Binding<TodoCategory.ID?> {
        Binding(
            get: {
                if let id = UUID(uuidString: lastUsedCategoryID),
                   store.categories.contains(where: { $0.id == id }) {
                    return id
                }
                return store.categories.first?.id
            },
            set: { lastUsedCategoryID = $0?.uuidString ?? "" }
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            if isAddingCategory {
                newCategoryField
                Divider()
            }
            list
            Divider()
            AddTaskField(categoryID: targetCategory)
            Divider()
            footer
        }
        .frame(width: 320)
    }

    private var header: some View {
        HStack(spacing: 8) {
            Text("SimplyDo")
                .font(.headline)

            Spacer()

            Text(openCount == 1 ? "1 open" : "\(openCount) open")
                .font(.caption)
                .monospacedDigit()
                .foregroundStyle(.secondary)

            Button(action: beginAddCategory) {
                Image(systemName: "folder.badge.plus")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help("New category")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var list: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if store.categories.isEmpty {
                    Text("No categories yet")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 28)
                }

                ForEach(store.categories) { category in
                    CategorySection(category: category)
                }
            }
            .padding(.vertical, 6)
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.size.height
            } action: { height in
                contentHeight = height
            }
        }
        .frame(height: min(contentHeight, Self.maxListHeight))
    }

    private var newCategoryField: some View {
        HStack(spacing: 6) {
            Image(systemName: "folder")
                .font(.caption2)
                .foregroundStyle(.secondary)

            TextField("Category name", text: $newCategoryName)
                .textFieldStyle(.plain)
                .font(.subheadline.weight(.semibold))
                .focused($isCategoryFieldFocused)
                .onSubmit(commitNewCategory)
                .onExitCommand(perform: cancelAddCategory)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
    }

    private var footer: some View {
        HStack {
            Spacer()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }

    private func beginAddCategory() {
        newCategoryName = ""
        isAddingCategory = true
        isCategoryFieldFocused = true
    }

    private func commitNewCategory() {
        if let id = store.addCategory(name: newCategoryName) {
            targetCategory.wrappedValue = id // new categories become the add target
        }
        cancelAddCategory()
    }

    private func cancelAddCategory() {
        newCategoryName = ""
        isAddingCategory = false
    }
}

#Preview {
    MenuContentView()
        .environmentObject(TodoStore.preview)
}
