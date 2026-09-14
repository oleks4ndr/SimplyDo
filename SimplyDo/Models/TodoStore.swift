//
//  TodoStore.swift
//  SimplyDo
//
//  Created by Oleksandr
//

import AppKit
import Combine
import Foundation

/// what actually lands on disk. schemaVersion is there so a future breaking
/// format change can spot old files - adding new optional fields to TodoItem
/// decodes fine into existing stores and does not need a bump.
struct StoreFile: Codable {
    var schemaVersion: Int = 1
    var categories: [TodoCategory]
}

@MainActor
final class TodoStore: ObservableObject {
    @Published var categories: [TodoCategory] = [] {
        didSet {
            guard !isLoading else { return }
            scheduleSave()
        }
    }

    /// nil when there is nowhere writable to save, and for previews
    private let fileURL: URL?
    private let saveDebounce: Duration = .milliseconds(400)
    private var saveTask: Task<Void, Never>?
    private var isLoading = false
    private var terminationObserver: (any NSObjectProtocol)?

    init(inMemory: Bool = false) {
        fileURL = inMemory ? nil : Self.makeFileURL()
        load()
        observeTermination()
    }

    deinit {
        if let terminationObserver {
            NotificationCenter.default.removeObserver(terminationObserver)
        }
    }

    // MARK: - Categories

    func addCategory(name: String) {
        guard let name = Self.clean(name) else { return }
        categories.append(TodoCategory(name: name))
    }

    func renameCategory(_ id: TodoCategory.ID, to name: String) {
        guard let name = Self.clean(name), let i = index(of: id) else { return }
        categories[i].name = name
    }

    func deleteCategory(_ id: TodoCategory.ID) {
        categories.removeAll { $0.id == id }
    }

    func toggleCollapsed(_ id: TodoCategory.ID) {
        guard let i = index(of: id) else { return }
        categories[i].isCollapsed.toggle()
    }

    // MARK: - Items

    func addItem(title: String, to categoryID: TodoCategory.ID) {
        guard let title = Self.clean(title), let i = index(of: categoryID) else { return }
        categories[i].items.append(TodoItem(title: title))
    }

    func toggleDone(_ itemID: TodoItem.ID, in categoryID: TodoCategory.ID) {
        guard let (c, t) = index(of: itemID, in: categoryID) else { return }
        let done = !categories[c].items[t].isDone
        categories[c].items[t].isDone = done
        categories[c].items[t].completedAt = done ? .now : nil
    }

    func renameItem(_ itemID: TodoItem.ID, in categoryID: TodoCategory.ID, to title: String) {
        guard let title = Self.clean(title),
              let (c, t) = index(of: itemID, in: categoryID) else { return }
        categories[c].items[t].title = title
    }

    func deleteItem(_ itemID: TodoItem.ID, in categoryID: TodoCategory.ID) {
        guard let c = index(of: categoryID) else { return }
        categories[c].items.removeAll { $0.id == itemID }
    }

    // MARK: - Lookup

    private func index(of categoryID: TodoCategory.ID) -> Int? {
        categories.firstIndex { $0.id == categoryID }
    }

    private func index(of itemID: TodoItem.ID, in categoryID: TodoCategory.ID) -> (Int, Int)? {
        guard let c = index(of: categoryID),
              let t = categories[c].items.firstIndex(where: { $0.id == itemID }) else { return nil }
        return (c, t)
    }

    private static func clean(_ text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    // MARK: - Loading

    private func load() {
        isLoading = true
        defer { isLoading = false }

        guard let fileURL else {
            categories = Self.seed()
            return
        }

        guard FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) else {
            categories = Self.seed()
            persist() // so the file exists from first launch, not first edit
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)
            categories = try Self.decoder.decode(StoreFile.self, from: data).categories
        } catch {
            // the file is meant to be user-readable, so a hand-edit breaking it is
            // an expected failure. keep a copy and carry on rather than crashing.
            quarantine(fileURL, because: error)
            categories = Self.seed()
        }
    }

    private static func seed() -> [TodoCategory] {
        [TodoCategory(name: "Tasks")]
    }

    private func quarantine(_ url: URL, because error: Error) {
        let stamp = ISO8601DateFormatter().string(from: .now).replacingOccurrences(of: ":", with: "-")
        let backup = url.appendingPathExtension("corrupt-\(stamp)")
        try? FileManager.default.moveItem(at: url, to: backup)
        NSLog("SimplyDo: could not read store (\(error)) - kept it as \(backup.lastPathComponent)")
    }

    // MARK: - Saving

    private func scheduleSave() {
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(for: saveDebounce)
            guard !Task.isCancelled else { return }
            persist()
        }
    }

    /// writes immediately, skipping the debounce
    func flush() {
        saveTask?.cancel()
        saveTask = nil
        persist()
    }

    private func persist() {
        guard let fileURL else { return }
        do {
            let data = try Self.encoder.encode(StoreFile(categories: categories))
            try data.write(to: fileURL, options: .atomic)
        } catch {
            NSLog("SimplyDo: save failed (\(error))")
        }
    }

    private func observeTermination() {
        terminationObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            // has to be synchronous - hopping to a new Task here would let the
            // process exit before a debounced edit ever reaches disk
            MainActor.assumeIsolated {
                self?.flush()
            }
        }
    }

    // MARK: - Coding

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    private static func makeFileURL() -> URL? {
        do {
            // app is sandboxed, so this lands in the container:
            // ~/Library/Containers/com.oleks4ndr.SimplyDo/Data/Library/Application Support
            let support = try FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            let folder = support.appending(path: "SimplyDo", directoryHint: .isDirectory)
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            return folder.appending(path: "store.json", directoryHint: .notDirectory)
        } catch {
            NSLog("SimplyDo: no writable store location (\(error)) - running in memory")
            return nil
        }
    }
}

extension TodoStore {
    /// sample data for #Preview. never touches disk.
    static var preview: TodoStore {
        let store = TodoStore(inMemory: true)
        store.categories = [
            TodoCategory(name: "Work", items: [
                TodoItem(title: "Ship the PR"),
                TodoItem(title: "Email Dana"),
                TodoItem(title: "Standup notes", isDone: true, completedAt: .now)
            ]),
            TodoCategory(name: "Home", items: [
                TodoItem(title: "Groceries"),
                TodoItem(title: "Call plumber")
            ]),
            TodoCategory(name: "Someday", isCollapsed: true, items: [
                TodoItem(title: "Learn Metal")
            ])
        ]
        return store
    }
}
