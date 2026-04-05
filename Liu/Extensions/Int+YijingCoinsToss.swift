//
//  Int+YijingCoinsToss.swift
//  Liu
//
//  Created by Ярослав on 20.02.2026.
//

import Foundation

extension Int {
    /// Three-coin method: each coin is heads (3) or tails (2).
    /// Sum produces 6 (old yin), 7 (young yang), 8 (young yin), or 9 (old yang).
    static func yijingCoinsToss() -> Int {
        (Bool.random() ? 3 : 2) +
        (Bool.random() ? 3 : 2) +
        (Bool.random() ? 3 : 2)
    }
}
