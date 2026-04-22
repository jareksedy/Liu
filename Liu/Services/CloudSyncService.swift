//
//  CloudSyncService.swift
//  Liu
//
//  Created by Ярослав on 20.04.2026.
//

import Foundation

enum CloudSyncService {
    private static let store = NSUbiquitousKeyValueStore.default
    private static let lineValuesKey = "syncedLineValues" // legacy key
    private static let castPayloadKey = "syncedCastPayload"
    private static let deviceIDKey = "cloudSyncDeviceID"
    static let didSyncNotification = Notification.Name("Liu.CloudSyncService.DidSync")

    struct SyncedCast: Codable {
        let values: [Int]
        let updatedAt: TimeInterval
        let sourceDeviceID: String
    }

    static var syncedKeys: Set<String> {
        [lineValuesKey, castPayloadKey]
    }

    /// Call once at launch to kick-start iCloud key-value sync.
    static func start() {
        store.synchronize()
    }

    static func saveLineValues(_ values: [Int], updatedAt: TimeInterval = Date().timeIntervalSince1970) {
        guard isValidLineValues(values) else { return }

        let payload = SyncedCast(
            values: values,
            updatedAt: updatedAt,
            sourceDeviceID: currentDeviceID
        )

        guard let data = try? JSONEncoder().encode(payload) else { return }
        store.set(data, forKey: castPayloadKey)
        store.set(values, forKey: lineValuesKey)
        store.synchronize()
    }

    static func loadSyncedCast() -> SyncedCast? {
        if let data = store.data(forKey: castPayloadKey),
           let payload = try? JSONDecoder().decode(SyncedCast.self, from: data),
           isValidLineValues(payload.values) {
            return payload
        }

        // Backward compatibility with the old raw array format.
        if let array = store.array(forKey: lineValuesKey) as? [Int],
           isValidLineValues(array) {
            return SyncedCast(values: array, updatedAt: 0, sourceDeviceID: "legacy")
        }

        return nil
    }

    static func clearLineValues() {
        store.removeObject(forKey: castPayloadKey)
        store.removeObject(forKey: lineValuesKey)
        store.synchronize()
    }

    private static var currentDeviceID: String {
        if let existing = UserDefaults.standard.string(forKey: deviceIDKey) {
            return existing
        }
        let created = UUID().uuidString
        UserDefaults.standard.set(created, forKey: deviceIDKey)
        return created
    }

    private static func isValidLineValues(_ values: [Int]) -> Bool {
        values.count == 6 && values.allSatisfy { (6...9).contains($0) }
    }
}
