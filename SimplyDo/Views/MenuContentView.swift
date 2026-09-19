//
//  MenuContentView.swift
//  SimplyDo
//
//  Created by Oleksandr
//

import SwiftUI

struct MenuContentView: View {
    @EnvironmentObject private var store: TodoStore

    @State private var isAddingCategory = false
    @State private var newCategoryName = ""
    @FocusState private var isCategoryFieldFocused: Bool

    @State private var contentHeight: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            header
            list
        }
        .frame(width: Metrics.popoverWidth)
        .background(AppColor.background)
    }

    private var header: some View {
        HStack(spacing: 8) {
            Text("SimplyDo")
                .font(.headline)
                .foregroundStyle(AppColor.textPrimary)

            Spacer()

            Button(action: beginAddCategory) {
                Label("Add Category", systemImage: "plus")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColor.textPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(AppColor.row))
            }
            .buttonStyle(.plain)
            .help("New category")

            Menu {
                Button("Quit SimplyDo") {
                    NSApplication.shared.terminate(nil)
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.callout)
                    .foregroundStyle(AppColor.textSecondary)
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
            .help("More")
        }
        .padding(.horizontal, Metrics.contentInset)
        .padding(.vertical, 12)
    }

    private var list: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Metrics.cardSpacing) {
                if isAddingCategory {
                    newCategoryField
                }

                if store.categories.isEmpty {
                    Text("No categories yet")
                        .font(.callout)
                        .foregroundStyle(AppColor.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 28)
                }

                ForEach(store.categories) { category in
                    CategorySection(category: category)
                }
            }
            .padding(.horizontal, Metrics.contentInset)
            .padding(.bottom, Metrics.contentInset)
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.size.height
            } action: { height in
                contentHeight = height
            }
        }
        .frame(height: min(contentHeight, Metrics.maxListHeight))
    }

    private var newCategoryField: some View {
        HStack(spacing: 6) {
            Image(systemName: "folder")
                .font(.caption2)
                .foregroundStyle(AppColor.textSecondary)

            TextField("Category name", text: $newCategoryName)
                .textFieldStyle(.plain)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColor.textPrimary)
                .focused($isCategoryFieldFocused)
                .onSubmit(commitNewCategory)
                .onExitCommand(perform: cancelAddCategory)
        }
        .padding(Metrics.cardPadding)
        .background(RoundedRectangle(cornerRadius: Metrics.cardCornerRadius).fill(AppColor.card))
    }

    private func beginAddCategory() {
        newCategoryName = ""
        isAddingCategory = true
        isCategoryFieldFocused = true
    }

    private func commitNewCategory() {
        store.addCategory(name: newCategoryName)
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
