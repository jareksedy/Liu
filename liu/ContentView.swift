//
//  ContentView.swift
//  liu
//
//  Created by Ярослав on 20.02.2026.
//

import AVFoundation
import SwiftUI

struct Line: Identifiable {
    let id = UUID()
    let value: Int // 6 = old yin, 7 = young yang, 8 = young yin, 9 = old yang

    var isYang: Bool { value == 7 || value == 9 }
    var isChanging: Bool { value == 6 || value == 9 }
}

enum Trigram {
    case heaven, earth, thunder, water, mountain, wind, fire, lake

    var chinese: String {
        switch self {
        case .heaven: "天"
        case .earth: "地"
        case .thunder: "雷"
        case .water: "水"
        case .mountain: "山"
        case .wind: "风"
        case .fire: "火"
        case .lake: "泽"
        }
    }

    /// Lookup by three lines (bottom to top), true = yang.
    static func find(_ lines: [Bool]) -> Trigram? {
        switch lines {
        case [true, true, true]:    .heaven
        case [false, false, false]: .earth
        case [true, false, false]:  .thunder
        case [false, true, false]:  .water
        case [false, false, true]:  .mountain
        case [false, true, true]:   .wind
        case [true, false, true]:   .fire
        case [true, true, false]:   .lake
        default: nil
        }
    }
}

struct ContentView: View {
    @State private var lines: [Line] = []
    @State private var result: Hexagram?
    @State private var relatingResult: Hexagram?
    @State private var isRestarting = false
    
    private var tossCount: Int { lines.count }
    private var isComplete: Bool { tossCount == 6 }
    
    private var lowerTrigram: Trigram? {
        guard tossCount >= 3 else { return nil }
        return Trigram.find(lines[0..<3].map(\.isYang))
    }
    
    private var upperTrigram: Trigram? {
        guard tossCount >= 6 else { return nil }
        return Trigram.find(lines[3..<6].map(\.isYang))
    }
    
    var body: some View {
        VStack(spacing: 12) {
            resultView(result: result, relatingResult: relatingResult)
                .animation(.easeInOut(duration: Constants.animationDuration * 1.75), value: result == nil)
                .padding(.bottom, 6)
            
            Divider()
            
            // Hexagram display — lines appear bottom-to-top
            HStack(spacing: 4) {
                // Numbers on the left
                VStack(spacing: Constants.lineSpacing) {
                    ForEach((0..<6).reversed(), id: \.self) { index in
                        LineNumberLabel(index: index, isTossed: index < tossCount, isChanging: index < tossCount && lines[index].isChanging)
                    }
                }
                
                // Lines
                VStack(spacing: Constants.lineSpacing) {
                    ForEach((0..<6).reversed(), id: \.self) { index in
                        if index < tossCount {
                            lineView(line: lines[index])
                                .id(lines[index].id)
                                .transition(.push(from: .bottom).combined(with: .opacity))
                        } else {
                            linePlaceholder()
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .animation(.snappy(duration: Constants.animationDuration, extraBounce: 0.35), value: tossCount)
                
                // Trigram names on the right
                VStack(spacing: Constants.lineSpacing) {
                    ForEach((0..<6).reversed(), id: \.self) { index in
                        if index == 2 || index == 5 {
                            let label = trigramLabel(for: index)
                            let isRevealed = label != " "
                            Text(label)
                                .font(Constants.monospacedRegularSmallFont)
                                .foregroundStyle(isRevealed ? Color(nsColor: .labelColor) : Color(nsColor: .quaternaryLabelColor))
                                .frame(width: Constants.lineLabelWidth, height: Constants.lineHeight, alignment: .center)
                                .contentTransition(.numericText())
                                .animation(.snappy(duration: Constants.animationDuration), value: label)
                        } else {
                            Color.clear
                                .frame(width: Constants.lineLabelWidth, height: Constants.lineHeight)
                        }
                    }
                }
            }
            .padding([.top, .bottom], Constants.hexagramTopBottomPadding)
            
            Divider()
            
            VStack(spacing: 12) {
                Button(action: toss) {
                    Group {
                        if isComplete && !isRestarting {
                            Text("Restart")
                        } else {
                            HStack(spacing: 0) {
                                Text("Toss Coins ")
                                Text("\(tossCount)")
                                    .monospacedDigit()
                                    .contentTransition(.numericText(countsDown: isRestarting))
                                    .animation(.snappy(duration: Constants.animationDuration), value: tossCount)
                                Text(" of 6")
                            }
                        }
                    }
                    .animation(.easeInOut(duration: 0.15), value: isComplete)
                    .animation(.easeInOut(duration: 0.15), value: isRestarting)
                }
                .keyboardShortcut(.return, modifiers: [])
                .buttonStyle(PrimaryButton())
                .padding(.horizontal, Constants.horizontalLinePadding)
                
                HStack {
                    PrimarySegmentedControl(
                        selection: .constant(0),
                        labels: ["←", "→"],
                        isEnabled: relatingResult != nil
                    )
                    Button(action: lookUp) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(PrimaryButton(isEnabled: result?.getSearchURL(relatingResult: relatingResult) != nil))
                    .aspectRatio(1, contentMode: .fit)
                    .disabled(result == nil)
                }
                .padding(.horizontal, Constants.horizontalLinePadding)
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(PrimaryButton())
                .font(Constants.monospacedRegularFont)
                .keyboardShortcut("q")
                .padding(.bottom, 2.5)
            }
        }
        .padding()
        .frame(width: 220)

    }
}

private extension ContentView {
    // MARK: - Helpers
    private func resultHeader(from result: Hexagram) -> String {
        let changingIndices = lines.enumerated()
            .filter { $0.element.isChanging }
            .map { "\($0.offset + 1)" }
        let changingPart = changingIndices.joined(separator: ".")
        return "\(result.id).\(changingPart) \(result.pinyin)"
    }
    
    private func trigramLabel(for index: Int) -> String {
        if index == 2, let trigram = lowerTrigram {
            return trigram.chinese
        }
        if index == 5, let trigram = upperTrigram {
            return trigram.chinese
        }
        return " "
    }
    
    // MARK: - Actions
    private func lookUp() {
        guard let url = result?.getSearchURL(relatingResult: relatingResult) else {
            return
        }
        NSWorkspace.shared.open(url)
    }
    
    private func toss() {
        guard !isRestarting else { return }
        guard !isComplete else {
            restart()
            return
        }
        
        let value = Int.yijingCoinsToss()
        lines.append(Line(value: value))
        
        playSound(.toss)
        
        if isComplete {
            result = HexagramLibrary.find(lines: lines.map(\.isYang))
            
            let hasChangingLines = lines.contains { $0.isChanging }
            if hasChangingLines {
                let relatingLines = lines.map { $0.isChanging ? !$0.isYang : $0.isYang }
                relatingResult = HexagramLibrary.find(lines: relatingLines)
            }
            
            playSound(.cast)
        }
    }
    
    private func restart() {
        isRestarting = true
        playSound(.drop)
        playSound(.restart)
        
        withAnimation(.easeInOut(duration: Constants.animationDuration * 1.25)) {
            result = nil
            relatingResult = nil
        }
        
        let count = lines.count
        for i in 0..<count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.restartLineDelay * Double(i)) {
                withAnimation(.snappy(duration: Constants.animationDuration, extraBounce: 0.25)) {
                    _ = lines.removeLast()
                }
                if lines.isEmpty {
                    isRestarting = false
                }
            }
        }
    }
    
    private func playSound(_ soundEffect: SoundEffect) {
        SoundEffect.playQueue.async {
            guard let data = SoundEffect.cache[soundEffect],
                  let player = try? AVAudioPlayer(data: data) else { return }
            if soundEffect == .toss {
                player.enableRate = true
                player.rate = .random(in: 0.8...1.4)
                player.volume = .random(in: 0.3...0.6)
                player.pan = .random(in: -1.0...1.0)
            } else {
                player.volume = 0.6
            }
            SoundEffect.activePlayers.removeAll { !$0.isPlaying }
            SoundEffect.activePlayers.append(player)
            player.play()
        }
    }
    
    private func resultView(result: Hexagram?, relatingResult: Hexagram?) -> some View {
        VStack(spacing: 5) {
            if let result {
                Text(resultHeader(from: result))
                    .font(Constants.monospacedBoldFont)
                Text(result.chinese)
                    .font(Constants.chineseCharacterFont)
                    .padding(.top, Constants.characterTopPadding)
                    .padding(.bottom, Constants.characterBottomPadding)
                Text(result.name)
                    .font(Constants.monospacedBoldFont)
                    .multilineTextAlignment(.center)
            } else {
                Text("Liù")
                    .font(Constants.monospacedBoldFont)
                Text("六")
                    .font(Constants.chineseCharacterFont)
                    .padding(.top, Constants.characterTopPadding)
                    .padding(.bottom, Constants.characterBottomPadding)
                Text("Menu Bar I Ching Oracle")
                    .font(Constants.monospacedBoldFont)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Line drawing
    private func lineView(line: Line) -> some View {
        ChangingLineColor(isChanging: line.isChanging) { color in
            HStack(spacing: line.isYang ? 0 : Constants.yinPadding) {
                if line.isYang {
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .frame(height: Constants.lineHeight)
                        .foregroundStyle(color)
                } else {
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .frame(height: Constants.lineHeight)
                        .foregroundStyle(color)
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .frame(height: Constants.lineHeight)
                        .foregroundStyle(color)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Constants.horizontalLinePadding)
        }
    }
    
    private func linePlaceholder() -> some View {
        RoundedRectangle(cornerRadius: Constants.cornerRadius)
            .frame(height: Constants.lineHeight)
            .foregroundStyle(.quaternary)
            .padding(.horizontal, Constants.horizontalLinePadding)
    }
}

private struct ChangingLineColor<Content: View>: View {
    let isChanging: Bool
    @ViewBuilder let content: (Color) -> Content
    @State private var highlighted = false

    var body: some View {
        content(highlighted ? Color(nsColor: .linkColor) : Color(nsColor: .labelColor))
            .animation(
                .easeInOut(duration: Constants.animationDuration)
                    .delay(Constants.changingLineColorDelay),
                value: highlighted
            )
            .onAppear {
                if isChanging { highlighted = true }
            }
            .onDisappear { highlighted = false }
    }
}

private struct LineNumberLabel: View {
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

private struct PrimaryButtonLabel<Label: View>: View {
    let label: Label
    let isPressed: Bool
    let isEnabled: Bool
    @State private var isHovered = false
    
    private var tint: Color {
        Color(nsColor: .linkColor).opacity(isEnabled ? 1 : 0.3)
    }
    
    var body: some View {
        label
            .font(Constants.monospacedRegularFont)
            .foregroundStyle(tint)
            .padding(9)
            .frame(maxWidth: .infinity)
            .background(isEnabled && isHovered ? Color(nsColor: .linkColor).opacity(0.1) : .clear)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(tint, lineWidth: 1)
            )
            .animation(.easeOut(duration: 0.1), value: isPressed)
            .animation(.easeInOut(duration: 0.1), value: isHovered)
            .animation(.easeInOut(duration: Constants.animationDuration), value: isEnabled)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

private struct PrimaryButton: ButtonStyle {
    var isEnabled: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        PrimaryButtonLabel(label: configuration.label, isPressed: configuration.isPressed, isEnabled: isEnabled)
    }
}

private struct PrimarySegmentedControl: View {
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
                Text(labels[index])
                    .font(Constants.monospacedRegularFont)
                    .foregroundStyle(tint)
                    .padding(9)
                    .frame(maxWidth: .infinity)
                    .background(
                        isEnabled && isSelected
                            ? Color(nsColor: .linkColor).opacity(0.15)
                            : (isEnabled && hoveredIndex == index ? Color(nsColor: .linkColor).opacity(0.07) : .clear)
                    )
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

extension Int {
    /// Three-coin method: each coin is heads (3) or tails (2).
    /// Sum produces 6 (old yin), 7 (young yang), 8 (young yin), or 9 (old yang).
    static func yijingCoinsToss() -> Int {
        (Bool.random() ? 3 : 2) +
        (Bool.random() ? 3 : 2) +
        (Bool.random() ? 3 : 2)
    }
}

fileprivate enum Constants {
    static let lookupButtonTopPadding: CGFloat = 10
    static let characterTopPadding: CGFloat = 14
    static let characterBottomPadding: CGFloat = 14
    static let chineseCharacterFont: Font = .custom("851tegakizatsu", size: 72)
    static let monospacedBoldFont: Font = .system(size: 12, weight: .bold, design: .monospaced)
    static let monospacedRegularFont: Font = .system(size: 12, weight: .regular, design: .monospaced)
    static let monospacedRegularSmallFont: Font = .system(size: 8, weight: .regular, design: .monospaced)
    static let monospacedRegularLargeFont: Font = .system(size: 48, weight: .ultraLight, design: .monospaced)
    static let animationDuration: TimeInterval = 0.25
    static let restartLineDelay: TimeInterval = 0.045
    static let hexagramTopBottomPadding: CGFloat = 10
    static let lineSpacing: CGFloat = 10
    static let cornerRadius: CGFloat = 3
    static let yinPadding: CGFloat = 20
    static let lineHeight: CGFloat = 10
    static let horizontalLinePadding: CGFloat = 2.5
    static let lineNumberLeading: CGFloat = 0
    static let lineLabelWidth: CGFloat = 14
    static let changingLineColorDelay: TimeInterval = 0.1
}

#Preview {
    ContentView()
}

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

