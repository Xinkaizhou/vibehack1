//
//  RewardSheet.swift
//  vibehack1
//
//  Created by Daniel on 2025/9/13.
//

import SwiftUI

// MARK: - 奖励弹窗
struct RewardSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    private var reward: Reward? {
        appState.currentRewardToShow
    }
    
    var body: some View {
        if let reward = reward {
            VStack(spacing: 0) {
                // 顶部标题栏
                ZStack {
                    // 右上角关闭按钮 - 参考Apple样式
                    HStack {
                        Spacer()
                        Button(action: {
                            claimAllViewedRewards()
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                                .frame(width: 30, height: 30)
                                .background(Color.black.opacity(0.08))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(Color(.windowBackgroundColor))
            
            // 内容区域
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    // 奖励标题
                    Text(reward.title)
                        .font(reward.type == .physicalReward ? .title2 : .title3)
                        .fontWeight(reward.type == .physicalReward ? .bold : .medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    if reward.type == .physicalReward {
                        // 实体奖励：优化的图片展示
                        if let imageName = reward.imageName {
                            VStack(spacing: 0) {
                                Image(imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: 320, maxHeight: 240)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
                            }
                            .padding(.horizontal, 8)
                        } else {
                            // 精美的占位图设计
                            VStack(spacing: 16) {
                                Image(systemName: "gift.circle.fill")
                                    .font(.system(size: 48))
                                    .foregroundStyle(.linearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                
                                Text("精美奖励图片")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: 320, maxHeight: 240)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.black.opacity(0.06), lineWidth: 1)
                                    )
                            )
                            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
                        }
                    }
                    
                    // 内容描述 - 优化版本
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: reward.type == .physicalReward ? "gift.fill" : "lightbulb.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(reward.type == .physicalReward ? .orange : .blue)
                            
                            Text(reward.type == .physicalReward ? "奖励详情" : "编程技巧")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                        
                        Text(reward.content)
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .lineSpacing(3)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                            )
                    )
                    
                }
                .padding(.horizontal, 32)
                .padding(.top, 24)
                .padding(.bottom, 140) // 为底部按钮留空间
            }
            .background(Color(.windowBackgroundColor))
            
            // 底部按钮区域
            VStack(spacing: 12) {
                // 如果还有其他未读奖励，显示"下一个"按钮
                if hasNextReward {
                    Button(action: {
                        showNextReward()
                    }) {
                        Text("下一个")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                LinearGradient(colors: [Color.blue, Color.blue.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                }
                
                // 历史奖励按钮 - 弱化版本
                Button(action: {
                    claimAllViewedRewards()
                    dismiss()
                    // 跳转到历史奖励页面
                    appState.currentView = .rewardHistory
                }) {
                    Text("历史奖励")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(Color.clear)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 24)
            .background(Color(.windowBackgroundColor))
            }
            .frame(width: 520, height: 640)
            .background(Color(.windowBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 8)
            .onAppear {
                // 自动领取当前奖励
                autoClaimCurrentReward()
            }
        } else {
            // 没有奖励时显示空状态
            VStack(spacing: 0) {
                // 顶部标题栏
                ZStack {
                    // 右上角关闭按钮
                    HStack {
                        Spacer()
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                                .frame(width: 30, height: 30)
                                .background(Color.black.opacity(0.08))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(Color(.windowBackgroundColor))
                
                // 内容区域
                VStack(spacing: 24) {
                    Spacer()
                    
                    // 空状态图标和文字
                    VStack(spacing: 20) {
                        Image(systemName: "gift")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.6))
                        
                        VStack(spacing: 8) {
                            Text("暂无新奖励")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text("完成祈福后会获得福报奖励")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(Color(.windowBackgroundColor))
                
                // 底部按钮
                VStack(spacing: 12) {
                    Button(action: {
                        dismiss()
                        appState.currentView = .rewardHistory
                    }) {
                        Text("查看历史奖励")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary.opacity(0.7))
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(Color.clear)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 24)
                .background(Color(.windowBackgroundColor))
            }
            .frame(width: 520, height: 640)
            .background(Color(.windowBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 8)
        }
    }
    
    private var formattedDate: String {
        guard let reward = reward else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: reward.timestamp)
    }
    
    // 计算是否还有下一个奖励 - 基于初始计数，不受动态移除影响
    private var hasNextReward: Bool {
        // 使用初始的未读奖励数量和当前索引来判断
        let initialCount = appState.initialUnreadRewardsCount
        let currentIndex = appState.currentRewardIndex
        return currentIndex < initialCount - 1
    }
    
    private func markCurrentAsRead() {
        guard let reward = reward else { return }
        if let index = appState.unreadRewards.firstIndex(where: { $0.id == reward.id }) {
            appState.unreadRewards[index].isRead = true
        }
    }
    
    private func autoClaimCurrentReward() {
        guard let reward = reward else { return }
        // 只标记为已读，不立即移除
        if let index = appState.unreadRewards.firstIndex(where: { $0.id == reward.id }) {
            appState.unreadRewards[index].isRead = true
        }
    }
    
    private func claimAllViewedRewards() {
        // 将所有已读的奖励移动到历史记录
        let viewedRewards = appState.unreadRewards.filter { $0.isRead }
        appState.allRewards.append(contentsOf: viewedRewards)
        appState.unreadRewards.removeAll { $0.isRead }
    }
    
    private func showNextReward() {
        let currentIndex = appState.currentRewardIndex
        let nextIndex = currentIndex + 1
        
        if nextIndex < appState.unreadRewards.count {
            // 有下一个奖励，显示它
            appState.currentRewardToShow = appState.unreadRewards[nextIndex]
            appState.currentRewardIndex = nextIndex
        } else {
            // 没有更多奖励，处理所有查看过的奖励并关闭弹窗
            claimAllViewedRewards()
            dismiss()
        }
    }
}

#Preview {
    let appState = AppState()
    
    // 添加测试奖励
    appState.currentRewardToShow = Reward(
        type: .physicalReward,
        title: "精美编程贴纸套装",
        content: "恭喜获得限量版编程贴纸套装！包含各种经典编程语言和框架的精美贴纸，让你的设备更加个性化。",
        imageName: nil
    )
    
    return RewardSheet()
        .environmentObject(appState)
}