//
//  SharedState.swift
//  Liu
//
//  Created by Ярослав on 03.04.2026.
//

import SwiftUI

@Observable
final class SharedState {
    var result: Hexagram?
    var relatingResult: Hexagram?
    var showingRelating: Bool
    
    init(
        result: Hexagram? = nil,
        relatingResult: Hexagram? = nil,
        showingRelating: Bool = false
    ) {
        self.result = result
        self.relatingResult = relatingResult
        self.showingRelating = showingRelating
    }
}
