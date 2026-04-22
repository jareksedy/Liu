//
//  liuApp.swift
//  liu
//
//  Created by Ярослав on 20.02.2026.
//

import AVFoundation
import FirebaseCore
import ServiceManagement
import SwiftUI

@main
struct LiuApp: App {
    @State private var sharedState: SharedState
    @State private var warmupPlayer: AVAudioPlayer?
    private static var cloudStoreObserver: NSObjectProtocol?
    
    init() {
        _sharedState = State(initialValue: Self.makeInitialSharedState())
        FirebaseApp.configure()
        CloudSyncService.start()
        Self.registerLaunchAtLoginIfNeeded()
        Self.startCloudStoreObserver()
        
        // Pre-load all sound data into memory
        _ = SoundEffect.cache
        
        // Play a silent sound to force the full audio pipeline to initialize
        if let data = SoundEffect.cache[.toss],
           let player = try? AVAudioPlayer(data: data) {
            player.volume = 0
            player.play()
            _warmupPlayer = State(initialValue: player)
        }
    }
    
    var body: some Scene {
        MenuBarExtra {
            LiuAppMainView()
                .environment(sharedState)
        } label: {
            let hexagram = sharedState.showingRelating ?
                sharedState.relatingResult : sharedState.result
            Image(nsImage: menuBarImage(for: hexagram))
        }
        .menuBarExtraStyle(.window)
    }

    private static let menuBarImageSize = CGSize(width: 18, height: 18)

    private static func makeInitialSharedState() -> SharedState {
        guard let cast = CloudSyncService.loadSyncedCast() else {
            return SharedState()
        }

        let lines = cast.values.map { Line(value: $0) }
        let result = HexagramLibrary.find(lines: lines.map(\.isYang))

        let relatingResult: Hexagram?
        if lines.contains(where: \.isChanging) {
            let relatingLines = lines.map { $0.isChanging ? !$0.isYang : $0.isYang }
            relatingResult = HexagramLibrary.find(lines: relatingLines)
        } else {
            relatingResult = nil
        }

        return SharedState(
            result: result,
            relatingResult: relatingResult,
            showingRelating: false
        )
    }

    private static func startCloudStoreObserver() {
        guard cloudStoreObserver == nil else { return }
        cloudStoreObserver = NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard shouldHandleCloudStoreDidChange(notification) else { return }
            NotificationCenter.default.post(name: CloudSyncService.didSyncNotification, object: nil)
        }
    }

    private static func registerLaunchAtLoginIfNeeded() {
        guard #available(macOS 13.0, *) else { return }
        guard !UserDefaults.standard.bool(forKey: Constants.autoStartRegistrationKey) else { return }

        do {
            try SMAppService.mainApp.register()
            UserDefaults.standard.set(true, forKey: Constants.autoStartRegistrationKey)
        } catch {
#if DEBUG
            print("Launch-at-login registration failed: \(error.localizedDescription)")
#endif
        }
    }

    private static func shouldHandleCloudStoreDidChange(_ notification: Notification) -> Bool {
        guard let userInfo = notification.userInfo else { return false }

        guard let reasonRaw = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int else {
            return false
        }
        guard reasonRaw == NSUbiquitousKeyValueStoreServerChange ||
                reasonRaw == NSUbiquitousKeyValueStoreInitialSyncChange else {
            return false
        }

        guard let changedKeys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] else {
            return false
        }
        return !Set(changedKeys).isDisjoint(with: CloudSyncService.syncedKeys)
    }

    private func menuBarImage(for hexagram: Hexagram?) -> NSImage {
        let text = hexagram?.unicodeSymbol ?? "六"
        let font = NSFont.monospacedSystemFont(ofSize: hexagram != nil ? 14 : 10, weight: hexagram != nil ? .regular : .bold)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.black
        ]

        let textSize = (text as NSString).size(withAttributes: attributes)
        let imageSize = Self.menuBarImageSize
        let image = NSImage(size: imageSize)
        image.lockFocus()

        let circleRect = NSRect(origin: .zero, size: imageSize).insetBy(dx: 0.5, dy: 0.5)
        let circle = NSBezierPath(ovalIn: circleRect)
        circle.lineWidth = 1
        NSColor.black.setStroke()
        circle.stroke()

        let origin = CGPoint(
            x: (imageSize.width - textSize.width) / 2 + (hexagram != nil ? 0 : 0.25),
            y: (imageSize.height - textSize.height) / 2 + (hexagram != nil ? 0.95 : 0.475)
        )
        (text as NSString).draw(at: origin, withAttributes: attributes)
        image.unlockFocus()
        image.isTemplate = true
        return image
    }
}

#Preview {
    LiuAppMainView()
        .environment(SharedState())
}
