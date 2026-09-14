//
//  AddTaskField.swift
//  SimplyDo
//
//  Created by Oleksandr
//

import SwiftUI

struct AddTaskField: View {
    @EnvironmentObject private var store: TodoStore

    @Binding var categoryID: TodoCategory.ID?

    @State private var text = ""
    @FocusState private var isFocused: Bool

    private var categoryName: String {
        store.categories.first { $0.id == categoryID }?.name ?? "No category"
    }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "plus")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            TextField("Add task", text: $text)
                .textFieldStyle(.plain)
                .font(.callout)
                .focused($isFocused)
                .onSubmit(commit)

            categoryMenu
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .task {
            try? await Task.sleep(for: .milliseconds(120))
            isFocused = true
        }
    }

    private var categoryMenu: some View {
        Menu {
            ForEach(store.categories) { category in
                Button(category.name) { categoryID = category.id }
            }
        } label: {
            Text(categoryName)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
        .disabled(store.categories.isEmpty)
        .help("Category for new tasks")
    }

    private func commit() {
        guard let categoryID else { return }
        withAnimation(.easeInOut(duration: 0.15)) {
            store.addItem(title: text, to: categoryID)
        }
        text = ""
        isFocused = true
    }
}

#Preview {
    let store = TodoStore.preview

    return AddTaskField(categoryID: .constant(store.categories[0].id))
        .frame(width: 320)
        .environmentObject(store)
}
