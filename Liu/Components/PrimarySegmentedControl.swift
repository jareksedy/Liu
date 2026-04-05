//
//  PrimarySegmentedControl.swift
//  Liu
//
//  Created by Ярослав on 20.02.2026.
//

import SwiftUI

struct PrimarySegmentedControl: View {
    @Binding var selection: Int
    let labels: [String]
    var isEnabled: Bool = true

    @State private var hoveredIndex: Int? = nil

    private var tint: Color {
        Color(nsColor: .linkColor).opacity(isEnabled ? 1 : 0.3)
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(labels.indices, id: \.self) { index in
                let isSelected = selection == index
                ZStack {
                    isEnabled && isSelected
                        ? Color(nsColor: .linkColor).opacity(0.1)
                        : (isEnabled && hoveredIndex == index ? Color(nsColor: .linkColor).opacity(0.1) : .clear)
                    Text(labels[index])
                        .font(Constants.monospacedRegularFont)
                        .foregroundStyle(tint)
                        .padding(9)
                        .offset(x: index == 0 ? 2 : (index == labels.count - 1 ? -2 : 0))
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onHover { hovering in
                    guard isEnabled else { return }
                    hoveredIndex = hovering ? index : nil
                }
                .onTapGesture {
                    guard isEnabled else { return }
                    selection = index
                }

                if index < labels.count - 1 {
                    Rectangle()
                        .fill(tint)
                        .frame(width: 1)
                        .padding(.vertical, 1)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .strokeBorder(tint, lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.1), value: selection)
        .animation(.easeInOut(duration: 0.1), value: hoveredIndex)
        .animation(.easeInOut(duration: Constants.animationDuration), value: isEnabled)
    }
}
