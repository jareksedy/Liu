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
                .animation(.easeInOut(duration: 0.4), value: isComplete)
            
            Divider()
            
            // Hexagram display — lines appear bottom-to-top
            VStack(spacing: 8) {
                ForEach((0 ..< 6).reversed(), id: \.self) { index in
                    if index < tossCount {
                        lineView(yang: lines[index])
                            .transition(.opacity.combined(with: .scale))
                    } else {
                        linePlaceholder()
                    }
                }
            }
            .animation(.easeInOut(duration: 0.4), value: tossCount)
            .frame(height: 108)
            
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
        if isComplete {
            lines = []
            result = nil
        }
        
        let yang = Bool.random()
        lines.append(yang)
        
        if lines.count == 6 {
            result = HexagramLibrary.find(lines: lines)
        }
    }
    
    private func resultView(result: Hexagram?) -> some View {
        VStack(spacing: 8) {
            if let result {
                Text("\(result.id)")
                    .font(.system(size: 12))
            } else {
                Text(result?.pinyin ?? "Liù")
                    .font(.system(size: 12))
            }

            Text(result?.chinese ?? "六")
                .font(.system(size: 48, weight: .regular))
            if let result {
                Text("\(result.pinyin) (\(result.name))")
                    .font(.system(size: 12))
                    .multilineTextAlignment(.center)
            } else {
                Text(result?.name ?? "Menu Bar Yi Jing Oracle")
                    .font(.system(size: 12))
                    .multilineTextAlignment(.center)
            }

            if let url = result?.searchURL {
                Button("Search Reading") {
                    NSWorkspace.shared.open(url)
                }
                .buttonStyle(.link)
                .font(.system(size: 12))
            } else {
                Button("About Liù") {
                    NSWorkspace.shared.open(URL(string: "https://github.com/jareksedy/Liu")!)
                }
                .buttonStyle(.link)
                .font(.system(size: 12))
            }
        }
    }
    
    // MARK: - Line drawing
    private func lineView(yang: Bool) -> some View {
        HStack(spacing: yang ? 0 : 26) {
            if yang {
                RoundedRectangle(cornerRadius: 2)
                    .frame(height: 10)
                    .foregroundStyle(.primary)
            } else {
                RoundedRectangle(cornerRadius: 2)
                    .frame(height: 10)
                    .foregroundStyle(.primary)
                RoundedRectangle(cornerRadius: 2)
                    .frame(height: 10)
                    .foregroundStyle(.primary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
    }
    
    private func linePlaceholder() -> some View {
        RoundedRectangle(cornerRadius: 2)
            .frame(height: 10)
            .foregroundStyle(.quaternary)
            .padding(.horizontal, 20)
    }
}
