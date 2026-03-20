//
//  ContentView.swift
//  liu
//
//  Created by Ярослав on 20.02.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var lines: [Bool] = []
    @State private var result: Hexagram?
    
    private var tossCount: Int { lines.count }
    private var isComplete: Bool { tossCount == 6 }
    
    var body: some View {
        VStack(spacing: 12) {
            resultView(result: result)
                .animation(.easeInOut(duration: Constants.animationDuration * 1.25), value: isComplete)
                .padding(.bottom, 10)
            
            Divider()
            
            // Hexagram display — lines appear bottom-to-top
            VStack(spacing: Constants.lineSpacing) {
                ForEach((0 ..< 6).reversed(), id: \.self) { index in
                    if index < tossCount {
                        lineView(yang: lines[index])
                            .transition(.blurReplace(.downUp).combined(with: .scale(0.75)))
                    } else {
                        linePlaceholder()
                    }
                }
            }
            .animation(.easeInOut(duration: Constants.animationDuration), value: tossCount)
            .padding([.top, .bottom], Constants.hexagramTopBottomPadding)
            
            Divider()
            
            HStack {
                Button(isComplete ? "Start Over" : "Toss Coins (\(tossCount)/6)") {
                    toss()
                }
                .keyboardShortcut(.return, modifiers: [])
                
                Spacer()
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q")
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
            lines = []
            result = nil
            return
        }
        
        let yang = Bool.yijingCoinsToss()
        lines.append(yang)
        
        if isComplete {
            result = HexagramLibrary.find(lines: lines)
        }
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

extension Bool {
    static func yijingCoinsToss() -> Bool {
        (Bool.random() ? 1 : 0) +
        (Bool.random() ? 1 : 0) +
        (Bool.random() ? 1 : 0) >= 2
    }
}

fileprivate enum Constants {
    static let characterTopPadding: CGFloat = 14
    static let characterBottomPadding: CGFloat = 13
    static let chineseCharacterFont: Font = .custom("WenYue_GuTiFangSong_F", size: 72)
    static let monospacedBoldFont: Font = .system(size: 12, weight: .bold, design: .monospaced)
    static let monospacedRegularFont: Font = .system(size: 12, weight: .regular, design: .monospaced)
    static let animationDuration: TimeInterval = 0.225
    static let hexagramTopBottomPadding: CGFloat = 10
    static let lineSpacing: CGFloat = 10
    static let cornerRadius: CGFloat = 1
    static let yinPadding: CGFloat = 20
    static let lineHeight: CGFloat = 10
    static let horizontalLinePadding: CGFloat = 20
}

#Preview {
    ContentView()
}
