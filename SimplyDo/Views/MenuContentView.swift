//
//  MenuContentView.swift
//  SimplyDo
//
//  Created by Oleksandr
//

import SwiftUI

struct MenuContentView: View {
    @EnvironmentObject private var store: TodoStore

    private var openCount: Int {
        store.categories.reduce(0) { $0 + ($1.items.count - $1.completedCount) }
    }

    var body: some View {
        // MenuBarExtra's window style doesn't size itself, so the width is fixed
        // here and the list is capped below
        VStack(spacing: 0) {
            header
            Divider()
            list
            Divider()
            footer
        }
        .frame(width: 320)
    }

    private var header: some View {
        HStack {
            Text("SimplyDo")
                .font(.headline)

            Spacer()

            Text(openCount == 1 ? "1 open" : "\(openCount) open")
                .font(.caption)
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var list: some View {
        if store.categories.isEmpty {
            Text("No categories yet")
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(store.categories) { category in
                        CategorySection(category: category)
                    }
                }
                .padding(.vertical, 6)
            }
            .frame(maxHeight: 420)
        }
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
}

#Preview {
    MenuContentView()
        .environmentObject(TodoStore.preview)
}
