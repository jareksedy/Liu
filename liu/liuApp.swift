//
//  liuApp.swift
//  liu
//
//  Created by Ярослав on 20.02.2026.
//

import SwiftUI

@main
struct liuApp: App {
    var body: some Scene {
        MenuBarExtra {
            ContentView()
        } label: {
            Text("六")
        }
        .menuBarExtraStyle(.window)
    }
}
