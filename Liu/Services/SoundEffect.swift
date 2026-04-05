//
//  SoundEffect.swift
//  Liu
//
//  Created by Ярослав on 20.02.2026.
//

import AVFoundation

nonisolated enum SoundEffect: CaseIterable, Hashable, Sendable {
    case toss
    case cast
    case drop
    case restart

    static let playQueue = DispatchQueue(label: "liu.sound", qos: .userInitiated)
    static var activePlayers: [AVAudioPlayer] = []

    static let cache: [SoundEffect: Data] = {
        var result: [SoundEffect: Data] = [:]
        for effect in SoundEffect.allCases {
            if let url = effect.url, let data = try? Data(contentsOf: url) {
                result[effect] = data
            }
        }
        return result
    }()

    var url: URL? {
        switch self {
        case .toss: return Bundle.main.url(forResource: "coin-toss", withExtension: "mp3")
        case .cast: return Bundle.main.url(forResource: "guzheng-3", withExtension: "mp3")
        case .drop: return Bundle.main.url(forResource: "coins-drop", withExtension: "mp3")
        case .restart: return Bundle.main.url(forResource: "guzheng-1", withExtension: "mp3")
        }
    }
}
