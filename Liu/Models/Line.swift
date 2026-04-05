//
//  Line.swift
//  Liu
//
//  Created by Ярослав on 20.02.2026.
//

import Foundation

struct Line: Identifiable {
    let id = UUID()
    let value: Int // 6 = old yin, 7 = young yang, 8 = young yin, 9 = old yang
    var isYang: Bool { value == 7 || value == 9 }
    var isChanging: Bool { value == 6 || value == 9 }
}
