//
//  LineNumberLabel.swift
//  Liu
//
//  Created by Ярослав on 20.02.2026.
//

import SwiftUI

struct LineNumberLabel: View {
    let index: Int
    let isTossed: Bool
    let isChanging: Bool

    private var color: Color {
        if isChanging { return Color(nsColor: .linkColor) }
        if isTossed { return Color(nsColor: .labelColor) }
        return Color(nsColor: .quaternaryLabelColor)
    }

    var body: some View {
        Text("\(index + 1)")
            .font(Constants.monospacedRegularSmallFont)
            .foregroundStyle(color)
            .frame(width: Constants.lineLabelWidth, height: Constants.lineHeight)
            .animation(
                .easeInOut(duration: Constants.animationDuration)
                    .delay(Constants.changingLineColorDelay),
                value: isChanging
            )
            .animation(.easeInOut(duration: Constants.animationDuration), value: isTossed)
    }
}
