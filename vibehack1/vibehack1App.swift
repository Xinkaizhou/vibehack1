//
//  vibehack1App.swift
//  vibehack1
//
//  Created by Daniel on 2025/9/11.
//

import SwiftUI

@main
struct vibehack1App: App {
    @State private var appState = AppState()
    @State private var timerManager: FocusTimerManager?
    @State private var menuBarManager: MenuBarManager?
    
    var body: some Scene {
        WindowGroup {
            if let timerManager = timerManager {
                MainView()
                    .environmentObject(appState)
                    .environmentObject(timerManager)
                    .frame(width: 650, height: 600)
            } else {
                // Loading view while initializing
                ProgressView("初始化中...")
                    .frame(width: 650, height: 600)
                    .onAppear {
                        initializeManagers()
                    }
            }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
    
    private func initializeManagers() {
        DispatchQueue.main.async {
            let timer = FocusTimerManager(appState: appState)
            let menuBar = MenuBarManager(appState: appState, timerManager: timer)
            
            self.timerManager = timer
            self.menuBarManager = menuBar
        }
    }
}
