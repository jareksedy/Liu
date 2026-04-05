//
//  PrimaryButton.swift
//  Liu
//
//  Created by Ярослав on 20.02.2026.
//

import SwiftUI

struct PrimaryButtonLabel<Label: View>: View {
    let label: Label
    let isPressed: Bool
    let isEnabled: Bool
    let isSquare: Bool
    @State private var isHovered = false

    private var tint: Color {
        Color(nsColor: .linkColor).opacity(isEnabled ? 1 : 0.3)
    }

    var body: some View {
        label
            .font(Constants.monospacedRegularFont)
            .foregroundStyle(tint)
            .padding(9)
            .frame(maxWidth: isSquare ? nil : .infinity)
            .frame(width: isSquare ? 34 : nil, height: isSquare ? 34 : nil)
            .background(isEnabled && isHovered ? Color(nsColor: .linkColor).opacity(0.1) : .clear)
            .clipShape(isSquare ? AnyShape(Circle()) : AnyShape(Capsule()))
            .overlay(
                Group {
                    if isSquare {
                        Circle().strokeBorder(tint, lineWidth: 1)
                    } else {
                        Capsule().strokeBorder(tint, lineWidth: 1)
                    }
                }
            )
            .animation(.easeOut(duration: 0.1), value: isPressed)
            .animation(.easeInOut(duration: 0.1), value: isHovered)
            .animation(.easeInOut(duration: Constants.animationDuration), value: isEnabled)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

struct PrimaryButton: ButtonStyle {
    var isEnabled: Bool = true
    var isSquare: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        PrimaryButtonLabel(label: configuration.label, isPressed: configuration.isPressed, isEnabled: isEnabled, isSquare: isSquare)
    }
}
