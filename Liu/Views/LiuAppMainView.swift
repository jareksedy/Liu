//
//  LiuAppMainView.swift
//  liu
//
//  Created by Ярослав on 20.02.2026.
//

import AVFoundation
import FirebaseAnalytics
import SwiftUI

struct LiuAppMainView: View {
    @Environment(SharedState.self) private var sharedState
    @State private var lines: [Line] = []
    @State private var showingRelating = false
    @State private var isRestarting = false
    @AppStorage(Constants.playSFXKey) private var playSFX = true

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
            VStack(spacing: 12) {
                resultView(result: sharedState.result, relatingResult: sharedState.relatingResult)
                    .animation(.easeInOut(duration: Constants.animationDuration * 1.75), value: sharedState.result == nil)
                    .padding(.bottom, 6)

                Divider()

                // Hexagram display — lines appear bottom-to-top
                HStack(spacing: 4) {
                    // Numbers on the left
                    VStack(spacing: Constants.lineSpacing) {
                        ForEach((0..<6).reversed(), id: \.self) { index in
                            LineNumberLabel(index: index, isTossed: index < tossCount, isChanging: !showingRelating && index < tossCount && lines[index].isChanging)
                        }
                    }

                    // Lines
                    VStack(spacing: Constants.lineSpacing) {
                        ForEach((0..<6).reversed(), id: \.self) { index in
                            if index < tossCount {
                                lineView(yang: displayedYang(for: index), isChanging: !showingRelating && lines[index].isChanging)
                                    .id(lines[index].id)
                                    .transition(.scale(scale: 0.75).combined(with: .opacity))
                            } else {
                                linePlaceholder()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .animation(.snappy(duration: Constants.animationDuration, extraBounce: 0.25), value: tossCount)

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
                                    .id(label)
                                    .transition(.asymmetric(insertion: .push(from: .leading).combined(with: .opacity), removal: .push(from: .trailing).combined(with: .opacity)))
                                    .animation(.snappy(duration: Constants.animationDuration), value: label)
                            } else {
                                Color.clear
                                    .frame(width: Constants.lineLabelWidth, height: Constants.lineHeight)
                            }
                        }
                    }
                }
                .padding(.horizontal, -Constants.hexagramNegativePadding)
                .padding([.top, .bottom], Constants.hexagramTopBottomPadding)
            }
            .id("content-\(showingRelating)")
            .transition(.opacity)

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

                HStack {
                    PrimarySegmentedControl(
                        selection: Binding(
                            get: { showingRelating ? 1 : 0 },
                            set: { newValue in withAnimation(.easeInOut(duration: Constants.animationDuration)) { showingRelating = newValue == 1 } }
                        ),
                        labels: [sharedState.result?.chinese ?? "1", sharedState.relatingResult?.chinese ?? "2"],
                        isEnabled: sharedState.relatingResult != nil
                    )
                    Button(action: lookUp) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(PrimaryButton(isEnabled: sharedState.result?.getSearchURL(relatingResult: sharedState.relatingResult) != nil, isSquare: true))
                    .disabled(sharedState.result == nil)
                    .keyboardShortcut("f")
                }
                .background {
                    Button("") {
                        guard sharedState.relatingResult != nil else { return }
                        withAnimation(.easeInOut(duration: Constants.animationDuration)) { showingRelating = false }
                    }
                    .keyboardShortcut(.leftArrow, modifiers: [])
                    .hidden()

                    Button("") {
                        guard sharedState.relatingResult != nil else { return }
                        withAnimation(.easeInOut(duration: Constants.animationDuration)) { showingRelating = true }
                    }
                    .keyboardShortcut(.rightArrow, modifiers: [])
                    .hidden()
                }

                HStack {
                    Button(action: toggleSFX) {
                        Image(systemName: playSFX ? "speaker.wave.2" : "speaker.slash")
                            .contentTransition(.symbolEffect(.replace))
                            .font(.system(size: 12))
                    }
                    .buttonStyle(PrimaryButton(isSquare: true))
                    .keyboardShortcut("m")

                    Button("Quit") {
                        NSApplication.shared.terminate(nil)
                    }
                    .buttonStyle(PrimaryButton())
                    .font(Constants.monospacedRegularFont)
                    .keyboardShortcut("q")
                }
            }
            .padding(.horizontal, Constants.horizontalLinePadding)
            .padding(.top, 5)
            .padding(.bottom, 2.5)
        }
        .padding()
        .frame(width: 220)
        .onChange(of: showingRelating) { _, newValue in
            sharedState.showingRelating = newValue
        }
    }
}

// MARK: - Helpers

private extension LiuAppMainView {
    func resultHeader(result: Hexagram, relatingResult: Hexagram?) -> String {
        if showingRelating, let relatingResult {
            return "\(relatingResult.id). \(relatingResult.chinese) \(relatingResult.pinyin)"
        }
        let changingIndices = lines.enumerated()
            .filter { $0.element.isChanging }
            .map { "\($0.offset + 1)" }
        let changingPart = changingIndices.joined(separator: ".")
        return "\(result.id).\(changingPart) \(result.chinese) \(result.pinyin)"
    }

    func displayedYang(for index: Int) -> Bool {
        guard index < tossCount else { return true }
        if showingRelating && lines[index].isChanging {
            return !lines[index].isYang
        }
        return lines[index].isYang
    }

    func trigramLabel(for index: Int) -> String {
        if showingRelating, let relatingResult = sharedState.relatingResult {
            if index == 2, let trigram = Trigram.find(Array(relatingResult.lines[0..<3])) {
                return trigram.chinese
            }
            if index == 5, let trigram = Trigram.find(Array(relatingResult.lines[3..<6])) {
                return trigram.chinese
            }
        } else {
            if index == 2, let trigram = lowerTrigram {
                return trigram.chinese
            }
            if index == 5, let trigram = upperTrigram {
                return trigram.chinese
            }
        }
        return " "
    }
}

// MARK: - Actions

private extension LiuAppMainView {
    func toggleSFX() {
        playSFX.toggle()
    }
    
    func aboutTheApp() {
        guard let url = URL(string: "https://liuapp.asia") else {
            return
        }
        NSWorkspace.shared.open(url)
        Analytics.logEvent("open_app_webpage", parameters: [:])
    }

    func lookUp() {
        guard let url = sharedState.result?.getSearchURL(relatingResult: sharedState.relatingResult) else {
            return
        }
        NSWorkspace.shared.open(url)
        Analytics.logEvent("hexagram_lookup", parameters: [
            "hexagram_id": sharedState.result?.id ?? 0
        ])
    }

    func toss() {
        guard !isRestarting else { return }
        guard !isComplete else {
            restart()
            return
        }

        let value = Int.yijingCoinsToss()
        lines.append(Line(value: value))

        playSound(.toss)

        if isComplete {
            sharedState.result = HexagramLibrary.find(lines: lines.map(\.isYang))

            let hasChangingLines = lines.contains { $0.isChanging }
            if hasChangingLines {
                let relatingLines = lines.map { $0.isChanging ? !$0.isYang : $0.isYang }
                sharedState.relatingResult = HexagramLibrary.find(lines: relatingLines)
            }

            playSound(.cast)

            Analytics.logEvent("hexagram_cast", parameters: [
                "hexagram_id": sharedState.result?.id ?? 0,
                "has_relating": hasChangingLines
            ])
        }
    }

    func restart() {
        Analytics.logEvent("hexagram_restart", parameters: nil)
        isRestarting = true
        withAnimation(.easeInOut(duration: Constants.animationDuration)) { showingRelating = false }
        playSound(.drop)
        playSound(.restart)

        withAnimation(.easeInOut(duration: Constants.animationDuration * 1.25)) {
            sharedState.result = nil
            sharedState.relatingResult = nil
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

    func playSound(_ soundEffect: SoundEffect) {
        guard playSFX else {
            return
        }
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
}

// MARK: - Subviews

private extension LiuAppMainView {
    func resultView(result: Hexagram?, relatingResult: Hexagram?) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if let result {
                let displayed = showingRelating ? (relatingResult ?? result) : result

                Text("\(resultHeader(result: result, relatingResult: relatingResult))")
                    .font(Constants.monospacedBoldFont)
                Text(displayed.name)
                    .font(Constants.monospacedRegularFont)
                Text("\(displayed.secondTrigramChinese) \(displayed.secondTrigramName) ⁄ \(displayed.firstTrigramChinese) \(displayed.firstTrigramName)")
                    .font(Constants.monospacedRegularFont)
                    .foregroundStyle(.secondary)
            } else {
                Text("六 Liù")
                    .font(Constants.monospacedBoldFont)
                Text("Menu Bar I Ching Oracle")
                    .font(Constants.monospacedRegularFont)
                Button(action: aboutTheApp) {
                    Text("About The App")
                }
                .font(Constants.monospacedRegularFont)
                .buttonStyle(.link)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    func lineView(yang: Bool, isChanging: Bool) -> some View {
        let color: Color = isChanging ? Color(nsColor: .linkColor) : Color(nsColor: .labelColor)
        return HStack(spacing: yang ? 0 : Constants.yinPadding) {
            if yang {
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
        .padding(.horizontal, Constants.horizontalHexagramPadding)
    }

    func linePlaceholder() -> some View {
        RoundedRectangle(cornerRadius: Constants.cornerRadius)
            .frame(height: Constants.lineHeight)
            .foregroundStyle(.quaternary)
            .padding(.horizontal, Constants.horizontalHexagramPadding)
    }
}

#Preview {
    LiuAppMainView()
        .environment(SharedState())
}
