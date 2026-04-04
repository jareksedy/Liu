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
            if let result = sharedState.result {
                Text("\(result.id)")
            } else {
                Text("六")
            }
        }
        .menuBarExtraStyle(.window)
    }
}
