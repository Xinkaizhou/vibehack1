//
//  NormalInfoBar.swift
//  vibehack1
//
//  Created by Daniel on 2025/9/13.
//

import SwiftUI

// MARK: - 正常状态信息栏
struct NormalInfoBar: View {
    @ObservedObject var timerManager: FocusTimerManager
    @EnvironmentObject var appState: AppState
    let onlineCount: Int
    @State private var lastRewardCount: Int = 0
    @State private var shouldAnimate: Bool = false
    @State private var rewardTapScale: CGFloat = 1.0
    @State private var rewardTextScale: CGFloat = 1.0
    
    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            
            // 在线蜡烛（左侧）
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 16))
                    Text("当前在线蜡烛")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                }
                
                Text("\(onlineCount) 对")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.black)
            }
            .frame(minWidth: 120)
            
            Spacer()
            
            Divider()
                .frame(height: 60)
            
            Spacer()
            
            // 本次蜡烛计时（中间）
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                    Text("本次祈福计时")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                }
                
                Text(formatTime(appState.currentFocusTime))
                    .font(.system(size: 22, weight: .semibold, design: .monospaced))
                    .foregroundColor(.black)
            }
            .frame(minWidth: 120)
            
            Spacer()
            
            Divider()
                .frame(height: 60)
            
            Spacer()
            
            // 福报池
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "gift.fill")
                        .foregroundColor(rewardDisplayColor)
                        .font(.system(size: 16))
                        .opacity(shouldAnimate ? 0.6 : 1.0)
                        .animation(
                            appState.unreadRewards.count > 0 ? 
                                .easeInOut(duration: 1.2).repeatForever(autoreverses: true) : 
                                .default,
                            value: shouldAnimate
                        )
                    Text("福报奖励")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                }
                
                Text(rewardStatusText)
                    .font(.system(size: 22))
                    .foregroundColor(rewardTextColor)
                    .scaleEffect(rewardTextScale)
                    .animation(
                        appState.unreadRewards.count > 0 ?
                            .easeInOut(duration: 1.0).repeatForever(autoreverses: true) :
                            .spring(response: 0.3, dampingFraction: 0.7),
                        value: rewardTextScale
                    )
            }
            .frame(minWidth: 120)
            .contentShape(Rectangle()) // 确保整个区域都可以点击
            .onTapGesture {
                if let firstReward = appState.unreadRewards.first {
                    // 有新奖励，显示奖励弹窗
                    appState.currentRewardToShow = firstReward
                    appState.isShowingRewardSheet = true
                } else {
                    // 没有新奖励，进入历史奖励页面
                    appState.currentView = .rewardHistory
                }
            }
            .scaleEffect(rewardTapScale)
            .onLongPressGesture(minimumDuration: 0.0, maximumDistance: .infinity, pressing: { isPressing in
                withAnimation(.easeInOut(duration: 0.1)) {
                    rewardTapScale = isPressing ? 0.95 : 1.0
                }
            }, perform: {})
            .onAppear {
                lastRewardCount = appState.unreadRewards.count
                shouldAnimate = appState.unreadRewards.count > 0
                rewardTextScale = appState.unreadRewards.count > 0 ? 1.05 : 1.0
            }
            .onChange(of: appState.unreadRewards.count) { oldCount, newCount in
                if newCount > lastRewardCount {
                    // 新奖励掉落时触发弹跳动画
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        shouldAnimate = true
                        rewardTextScale = 1.2
                    }
                    
                    // 延迟开始呼吸动画
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        if newCount > 0 {
                            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                                rewardTextScale = 1.05
                            }
                        }
                        shouldAnimate = newCount > 0
                    }
                } else if newCount == 0 {
                    // 没有奖励时停止动画
                    withAnimation(.easeOut(duration: 0.3)) {
                        rewardTextScale = 1.0
                        shouldAnimate = false
                    }
                } else if oldCount == 0 && newCount > 0 {
                    // 从无奖励到有奖励，开始呼吸动画
                    withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                        rewardTextScale = 1.05
                    }
                    shouldAnimate = true
                }
                lastRewardCount = newCount
            }
            
            Spacer()
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
    }
    
    // 直接在View中格式化时间，确保能观察到AppState变化
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let totalSeconds = Int(timeInterval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    // 动态文案逻辑
    private var rewardStatusText: String {
        let rewardCount = appState.unreadRewards.count
        
        if rewardCount > 0 {
            return "收到 \(rewardCount) 个新奖励"
        } else {
            switch appState.focusState {
            case .focusing:
                return "等待奖励掉落"
            case .idle, .paused:
                return "计时后发放"
            }
        }
    }
    
    // 动态颜色逻辑
    private var rewardDisplayColor: Color {
        return appState.unreadRewards.count > 0 ? .red : .pink
    }
    
    private var rewardTextColor: Color {
        return appState.unreadRewards.count > 0 ? .red : .black.opacity(0.6)
    }
}

#Preview {
    let appState = AppState()
    let timerManager = FocusTimerManager(appState: appState)
    
    NormalInfoBar(timerManager: timerManager, onlineCount: 1024)
        .environmentObject(appState)
        .frame(width: 650, height: 200)
}
