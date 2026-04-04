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

    private static let menuBarImageSize = CGSize(width: 32, height: 18)

    private func menuBarImage(for hexagram: Hexagram?) -> NSImage {
        let attributed: NSAttributedString
        if let hexagram {
            let idFont = NSFont.monospacedSystemFont(ofSize: 10, weight: .bold)
            let symbolFont = NSFont.monospacedSystemFont(ofSize: 14, weight: .bold)
            let baselineOffset = (symbolFont.capHeight - idFont.capHeight) / 2
            let idPart = NSAttributedString(string: "\(hexagram.id).", attributes: [
                .font: idFont,
                .foregroundColor: NSColor.black,
                .baselineOffset: baselineOffset
            ])
            let symbolPart = NSAttributedString(string: hexagram.unicodeSymbol, attributes: [
                .font: symbolFont,
                .foregroundColor: NSColor.black
            ])
            let result = NSMutableAttributedString()
            result.append(idPart)
            result.append(symbolPart)
            attributed = result
        } else {
            attributed = NSAttributedString(string: "六", attributes: [
                .font: NSFont.monospacedSystemFont(ofSize: 8, weight: .black),
                .foregroundColor: NSColor.black
            ])
        }

        let textSize = attributed.size()
        let imageSize = Self.menuBarImageSize
        let image = NSImage(size: imageSize)
        image.lockFocus()

        if hexagram == nil {
            // Filled circle centered in the image, with the character knocked out
            let diameter = imageSize.height
            let circleRect = NSRect(
                x: (imageSize.width - diameter) / 2,
                y: 0,
                width: diameter,
                height: diameter
            )
            let circle = NSBezierPath(ovalIn: circleRect.insetBy(dx: 0.5, dy: 0.5))
            circle.lineWidth = 1
            NSColor.black.setStroke()
            circle.stroke()
        }

        let origin = CGPoint(
            x: (imageSize.width - textSize.width) / 2,
            y: (imageSize.height - textSize.height) / 2
        )
        attributed.draw(at: origin)
        image.unlockFocus()
        image.isTemplate = true
        return image
    }
}

#Preview {
    LiuAppMainView()
        .environment(SharedState())
}
