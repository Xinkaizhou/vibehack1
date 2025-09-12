//
//  RewardDetailView.swift
//  vibehack1
//
//  Created by Daniel on 2025/9/12.
//

import SwiftUI

struct RewardDetailView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentRewardIndex = 0
    
    var body: some View {
        VStack(spacing: 30) {
            // 标题区域
            VStack(spacing: 16) {
                Text("✨ 锦囊开启 ✨")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .scaleEffect(1.2)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: UUID())
                
                if !appState.unreadRewards.isEmpty {
                    Text("第 \(currentRewardIndex + 1) / \(appState.unreadRewards.count) 个")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // 内容区域
            if appState.unreadRewards.isEmpty {
                EmptyRewardView()
            } else {
                RewardContentView(reward: appState.unreadRewards[currentRewardIndex])
            }
            
            Spacer()
            
            // 操作按钮
            ActionButtonsView(currentIndex: $currentRewardIndex)
        }
        .padding()
        .background(Color(.windowBackgroundColor))
        .onAppear {
            // 标记当前锦囊为已读
            markCurrentRewardAsRead()
        }
    }
    
    private func markCurrentRewardAsRead() {
        if !appState.unreadRewards.isEmpty && currentRewardIndex < appState.unreadRewards.count {
            appState.unreadRewards[currentRewardIndex].isRead = true
        }
    }
}

struct EmptyRewardView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "gift")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("暂无新锦囊")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Text("专注时会有锦囊随机掉落，\n完成专注后必定获得锦囊奖励")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct RewardContentView: View {
    let reward: Reward
    
    var body: some View {
        VStack(spacing: 20) {
            // 奖励类型和稀有度
            HStack {
                rewardTypeIcon
                    .font(.title2)
                    .foregroundColor(reward.rarity.color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(reward.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(rewardTypeName) - \(reward.rarity.displayName)")
                        .font(.caption)
                        .foregroundColor(reward.rarity.color)
                }
                
                Spacer()
            }
            
            Divider()
            
            // 锦囊内容
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(reward.content)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                    
                    // 时间戳
                    HStack {
                        Spacer()
                        Text("获得于 \(formattedDate)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.controlBackgroundColor))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(reward.rarity.color.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .frame(maxHeight: 200)
        }
        .animation(.easeInOut(duration: 0.3), value: reward.id)
    }
    
    private var rewardTypeIcon: Image {
        switch reward.type {
        case .programmingTip:
            return Image(systemName: "lightbulb.fill")
        case .motivation:
            return Image(systemName: "heart.fill")
        case .achievement:
            return Image(systemName: "star.fill")
        case .blessing:
            return Image(systemName: "sparkles")
        }
    }
    
    private var rewardTypeName: String {
        switch reward.type {
        case .programmingTip:
            return "编程技巧"
        case .motivation:
            return "专注激励"
        case .achievement:
            return "成就奖励"
        case .blessing:
            return "祝福锦囊"
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: reward.timestamp)
    }
}

struct ActionButtonsView: View {
    @EnvironmentObject var appState: AppState
    @Binding var currentIndex: Int
    
    var body: some View {
        HStack(spacing: 20) {
            // 下一个按钮
            if !appState.unreadRewards.isEmpty && currentIndex < appState.unreadRewards.count - 1 {
                Button("下一个") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentIndex += 1
                    }
                    markCurrentRewardAsRead()
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            
            // 收藏按钮（预留功能）
            if !appState.unreadRewards.isEmpty {
                Button("收藏") {
                    // TODO: 实现收藏功能
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            
            // 返回按钮
            Button("返回") {
                cleanupAndReturn()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
    
    private func markCurrentRewardAsRead() {
        if !appState.unreadRewards.isEmpty && currentIndex < appState.unreadRewards.count {
            appState.unreadRewards[currentIndex].isRead = true
        }
    }
    
    private func cleanupAndReturn() {
        // 清理已读的锦囊
        appState.unreadRewards.removeAll { $0.isRead }
        
        // 重置索引
        currentIndex = 0
        
        // 返回主页面
        appState.currentView = .main
    }
}

#Preview {
    let appState = AppState()
    let timerManager = FocusTimerManager(appState: appState)
    
    // 添加一些测试锦囊
    DispatchQueue.main.async {
        appState.unreadRewards = [
            Reward(type: .programmingTip, title: "编程小贴士", content: "使用 Cursor 时，尝试编写更详细的注释，AI 会根据注释生成更准确的代码建议。保持注释的简洁明了，描述代码的意图而不是实现细节。", rarity: .common),
            Reward(type: .motivation, title: "专注祝贺", content: "恭喜完成一段专注时光！持续的专注是通向成功的阶梯，每一分钟的专注都在为你的目标添砖加瓦。", rarity: .rare)
        ]
    }
    
    return RewardDetailView()
        .environmentObject(appState)
        .environmentObject(timerManager)
        .frame(width: 400, height: 600)
}