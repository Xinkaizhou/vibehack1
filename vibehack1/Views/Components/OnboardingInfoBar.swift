//
//  OnboardingInfoBar.swift
//  vibehack1
//
//  Created by Daniel on 2025/9/13.
//

import SwiftUI

// MARK: - 新用户引导信息栏
struct OnboardingInfoBar: View {
    @EnvironmentObject var appState: AppState
    @State private var showContent = false
    
    var body: some View {
        HStack {
            if showContent {
                VStack(spacing: 8) {
                    Text(titleText)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text(subtitleText)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity)  // 确保背景填充整个宽度
        .padding(.horizontal, 40)  // 减少两边留空
        .frame(height: 100)
        .background(
            LinearGradient(
                colors: [
                    Color(.sRGB, red: 0.95, green: 0.93, blue: 0.89),
                    Color(.sRGB, red: 0.92, green: 0.90, blue: 0.86),
                    Color(.sRGB, red: 0.90, green: 0.88, blue: 0.84)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(
            Rectangle()
                .fill(Color.black.opacity(0.1))
                .frame(height: 1),
            alignment: .bottom
        )
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                showContent = true
            }
        }
        .onChange(of: appState.onboardingStep) { _, newStep in
            withAnimation(.easeInOut(duration: 0.4)) {
                showContent = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showContent = true
                }
            }
        }
    }
    
    private var titleText: String {
        switch appState.onboardingStep {
        case .welcome:
            return "码祖庙 - 你的 vibecoding 守护神"
        case .targetSelected:
            return "点击任意蜡烛，开始或结束祈福"
        case .completed:
            return ""
        }
    }
    
    private var subtitleText: String {
        switch appState.onboardingStep {
        case .welcome:
            return "两步即可祈福"
        case .targetSelected, .completed:
            return ""
        }
    }
}

#Preview {
    let appState = AppState()
    
    VStack(spacing: 20) {
        OnboardingInfoBar()
            .environmentObject(appState)
        
        HStack {
            Button("步骤1") {
                appState.onboardingStep = .welcome
            }
            Button("步骤2") {
                appState.onboardingStep = .targetSelected
            }
            Button("完成") {
                appState.onboardingStep = .completed
            }
        }
    }
    .frame(width: 650, height: 300)
}