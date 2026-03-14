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
            Text(result?.pinyin ?? "Liù")
                .font(.system(size: 12))
            Text(result?.chinese ?? "六")
                .font(.system(size: 48, weight: .regular))
            Text(result?.name ?? "A Quiet Yi Jing Oracle")
                .font(.system(size: 12))
                .multilineTextAlignment(.center)
            if let url = result?.searchURL {
                Button("Search Interpretation") {
                    NSWorkspace.shared.open(url)
                }
                .buttonStyle(.link)
                .font(.system(size: 10))
            } else {
                Text("In Your Menu Bar")
                    .font(.system(size: 10))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
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
