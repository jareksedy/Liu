//
//  liuApp.swift
//  liu
//
//  Created by Ярослав on 20.02.2026.
//

import AVFoundation
import SwiftUI

@main
struct LiuApp: App {
    @State private var sharedState = SharedState()
    @State private var warmupPlayer: AVAudioPlayer?
    
    init() {
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
            Image(
                nsImage: menuBarImage(
                    for: getStatus(
                        for: sharedState.showingRelating ?
                        sharedState.relatingResult : sharedState.result
                    )
                )
            )
        }
        .menuBarExtraStyle(.window)
    }
    
    private static let menuBarImageSize = CGSize(width: 36, height: 18)
    private static let menuBarFont = NSFont.monospacedSystemFont(ofSize: 10, weight: .bold)
    
    private func getStatus(for hexagram: Hexagram?) -> String {
        guard let hexagram else {
            return "六"
        }
        return "\(hexagram.id). \(hexagram.unicodeSymbol)"
    }

    private func menuBarImage(for text: String) -> NSImage {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: Self.menuBarFont,
            .foregroundColor: NSColor.black
        ]
        let textSize = (text as NSString).size(withAttributes: attributes)
        let imageSize = Self.menuBarImageSize
        let image = NSImage(size: imageSize)
        image.lockFocus()
        let origin = CGPoint(
            x: (imageSize.width - textSize.width) / 2,
            y: (imageSize.height - textSize.height) / 2
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
