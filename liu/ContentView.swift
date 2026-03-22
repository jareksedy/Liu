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
    let yang: Bool
}

struct ContentView: View {
    @State private var lines: [Line] = []
    @State private var result: Hexagram?
    @State private var audioPlayers: [AVAudioPlayer] = []
    @State private var isRestarting = false
    
    private var tossCount: Int { lines.count }
    private var isComplete: Bool { tossCount == 6 }
    
    var body: some View {
        VStack(spacing: 12) {
            resultView(result: result)
                .animation(.easeInOut(duration: Constants.animationDuration * 1.75), value: result == nil)
                .padding(.bottom, 6)
            
            Divider()
            
            // Hexagram display — lines appear bottom-to-top
            VStack(spacing: Constants.lineSpacing) {
                ForEach((0..<6).reversed(), id: \.self) { index in
                    if index < tossCount {
                        lineView(yang: lines[index].yang)
                            .id(lines[index].id)
                            .transition(.scale(scale: 0.75, anchor: .center).combined(with: .opacity))
                    } else {
                        linePlaceholder()
                    }
                }
            }
            .animation(.snappy(duration: Constants.animationDuration, extraBounce: 0.25), value: tossCount)
            .padding([.top, .bottom], Constants.hexagramTopBottomPadding)
            
            Divider()
            
            VStack(spacing: 12) {
                Button(isComplete || isRestarting ? "Restart" : "Toss Coins \(tossCount) of 6") {
                    toss()
                }
                .keyboardShortcut(.return, modifiers: [])
                .disabled(isRestarting)
                .buttonStyle(PrimaryButton())
                .padding(.horizontal, Constants.horizontalLinePadding - 4)
                .padding(.top, 6)
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.link)
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
    // MARK: - Actions
    private func toss() {
        guard !isComplete else {
            restart()
            return
        }
        
        let yang = Bool.yijingCoinsToss()
        lines.append(Line(yang: yang))
        
        playSound(.toss)
        
        if isComplete {
            result = HexagramLibrary.find(lines: lines.map(\.yang))
            playSound(.cast)
        }
    }
    
    private func restart() {
        isRestarting = true
        playSound(.restart)
        
        withAnimation(.easeInOut(duration: Constants.animationDuration * 1.25)) {
            result = nil
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
        guard let url = soundEffect.url,
              let player = try? AVAudioPlayer(contentsOf: url) else { return }
        if soundEffect == .toss {
            player.enableRate = true
            player.rate = Float.random(in: 0.8...1.2)
            player.volume = Float.random(in: 0.4...1.0)
            player.pan = Float.random(in: -1.0...1.0)
        }
        audioPlayers.removeAll { !$0.isPlaying }
        audioPlayers.append(player)
        player.play()
    }
    
    private func resultView(result: Hexagram?) -> some View {
        VStack(spacing: 8) {
            if let result {
                Text("\(result.id). \(result.pinyin)")
                    .font(Constants.monospacedBoldFont)
                Text(result.chinese)
                    .font(Constants.chineseCharacterFont)
                    .padding(.top, Constants.characterTopPadding)
                    .padding(.bottom, Constants.characterBottomPadding)
                Text("\(result.name)")
                    .font(Constants.monospacedBoldFont)
                    .multilineTextAlignment(.center)
                if let url = result.searchURL {
                    Button("Look It Up →") {
                        NSWorkspace.shared.open(url)
                    }
                    .buttonStyle(.link)
                    .font(Constants.monospacedRegularFont)
                    .padding(.trailing, -3.5)
                    .padding(.top, Constants.lookupButtonTopPadding)
                }
            } else {
                Text("Liù")
                    .font(Constants.monospacedBoldFont)
                Text("六")
                    .font(Constants.chineseCharacterFont)
                    .padding(.top, Constants.characterTopPadding)
                    .padding(.bottom, Constants.characterBottomPadding)
                Text("Menu Bar Yì Jīng App")
                    .font(Constants.monospacedBoldFont)
                    .multilineTextAlignment(.center)
                Button("About Liù") {
                    NSWorkspace.shared.open(URL(string: "https://github.com/jareksedy/Liu")!)
                }
                .buttonStyle(.link)
                .font(Constants.monospacedRegularFont)
                .padding(.top, Constants.lookupButtonTopPadding)
            }
        }
    }
    
    // MARK: - Line drawing
    private func lineView(yang: Bool) -> some View {
        HStack(spacing: yang ? 0 : Constants.yinPadding) {
            if yang {
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .frame(height: Constants.lineHeight)
                    .foregroundStyle(Color(nsColor: .labelColor))
            } else {
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .frame(height: Constants.lineHeight)
                    .foregroundStyle(Color(nsColor: .labelColor))
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .frame(height: Constants.lineHeight)
                    .foregroundStyle(Color(nsColor: .labelColor))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Constants.horizontalLinePadding)
    }
    
    private func linePlaceholder() -> some View {
        RoundedRectangle(cornerRadius: Constants.cornerRadius)
            .frame(height: Constants.lineHeight)
            .foregroundStyle(.quaternary)
            .padding(.horizontal, Constants.horizontalLinePadding)
    }
}

private struct PrimaryButton: ButtonStyle {
    @State private var isHovered = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Constants.monospacedRegularFont)
            .foregroundStyle(Color(nsColor: .linkColor))
            .padding(9)
            .frame(maxWidth: .infinity)
            .background(isHovered ? Color(nsColor: .linkColor).opacity(0.1) : .clear)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(Color(nsColor: .linkColor), lineWidth: 1)
            )
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
            .animation(.easeInOut(duration: 0.1), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

extension Bool {
    static func yijingCoinsToss() -> Bool {
        (Bool.random() ? 1 : 0) +
        (Bool.random() ? 1 : 0) +
        (Bool.random() ? 1 : 0) >= 2
    }
}

fileprivate enum Constants {
    static let lookupButtonTopPadding: CGFloat = 5
    static let characterTopPadding: CGFloat = 14
    static let characterBottomPadding: CGFloat = 12
    static let chineseCharacterFont: Font = .custom("WenYue_GuTiFangSong_F", size: 72)
    static let monospacedBoldFont: Font = .system(size: 12, weight: .bold, design: .monospaced)
    static let monospacedRegularFont: Font = .system(size: 12, weight: .regular, design: .monospaced)
    static let animationDuration: TimeInterval = 0.25
    static let restartLineDelay: TimeInterval = 0.045
    static let hexagramTopBottomPadding: CGFloat = 10
    static let lineSpacing: CGFloat = 10
    static let cornerRadius: CGFloat = 2
    static let yinPadding: CGFloat = 20
    static let lineHeight: CGFloat = 10
    static let horizontalLinePadding: CGFloat = 20
}

#Preview {
    ContentView()
}

enum SoundEffect {
    case toss
    case cast
    case restart
    
    var url: URL? {
        switch self {
        case .toss:
            return Bundle.main.url(forResource: "coin-toss", withExtension: "mp3")
        case .cast:
            return Bundle.main.url(forResource: "guzheng-1", withExtension: "mp3")
        case .restart:
            return Bundle.main.url(forResource: "guzheng-2", withExtension: "mp3")
        }
    }
}

