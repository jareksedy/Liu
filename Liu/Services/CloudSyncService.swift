//
//  CloudSyncService.swift
//  Liu
//
//  Created by Ярослав on 20.04.2026.
//

import Foundation

enum CloudSyncService {
    private static let store = NSUbiquitousKeyValueStore.default
    private static let lineValuesKey = "syncedLineValues"

    /// Call once at launch to kick-start iCloud key-value sync.
    static func start() {
        store.synchronize()
    }

    static func saveLineValues(_ values: [Int]) {
        store.set(values, forKey: lineValuesKey)
    }

    static func loadLineValues() -> [Int]? {
        guard let array = store.array(forKey: lineValuesKey) as? [Int],
              array.count == 6 else { return nil }
        return array
    }
}
