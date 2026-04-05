//
//  Trigram.swift
//  Liu
//
//  Created by Ярослав on 20.02.2026.
//

import Foundation

enum Trigram {
    case heaven, earth, thunder, water, mountain, wind, fire, lake

    var name: String {
        switch self {
        case .heaven: "Heaven"
        case .earth: "Earth"
        case .thunder: "Thunder"
        case .water: "Water"
        case .mountain: "Mountain"
        case .wind: "Wind"
        case .fire: "Fire"
        case .lake: "Lake"
        }
    }

    var chinese: String {
        switch self {
        case .heaven: "乾"
        case .earth: "坤"
        case .thunder: "震"
        case .water: "坎"
        case .mountain: "艮"
        case .wind: "巽"
        case .fire: "離"
        case .lake: "兌"
        }
    }

    /// Lookup by three lines (bottom to top), true = yang.
    static func find(_ lines: [Bool]) -> Trigram? {
        switch lines {
        case [true, true, true]: .heaven
        case [false, false, false]: .earth
        case [true, false, false]: .thunder
        case [false, true, false]: .water
        case [false, false, true]: .mountain
        case [false, true, true]: .wind
        case [true, false, true]: .fire
        case [true, true, false]: .lake
        default: nil
        }
    }
}
