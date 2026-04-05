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
            let hexagram = sharedState.showingRelating ?
                sharedState.relatingResult : sharedState.result
            Image(nsImage: menuBarImage(for: hexagram))
        }
        .menuBarExtraStyle(.window)
    }

    private static let menuBarImageSize = CGSize(width: 18, height: 18)

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
