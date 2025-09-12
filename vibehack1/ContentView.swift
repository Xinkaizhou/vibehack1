//
//  MainView.swift
//  vibehack1
//
//  Created by Daniel on 2025/9/12.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var timerManager: FocusTimerManager
    
    var body: some View {
        NavigationStack {
            switch appState.currentView {
            case .main:
                MainGameView()
            case .rewardDetail:
                RewardDetailView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.currentView)
    }
}

#Preview {
    let appState = AppState()
    let timerManager = FocusTimerManager(appState: appState)
    
    MainView()
        .environmentObject(appState)
        .environmentObject(timerManager)
        .frame(width: 400, height: 600)
}
