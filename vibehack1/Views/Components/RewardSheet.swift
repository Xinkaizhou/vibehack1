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
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    if reward.type == .physicalReward {
                        // 实体奖励：图片展示或占位图
                        if let imageName = reward.imageName {
                            Image(imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 300, maxHeight: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        } else {
                            // 占位图
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.2))
                                .frame(maxWidth: 300, maxHeight: 200)
                                .overlay(
                                    VStack(spacing: 8) {
                                        Image(systemName: "gift.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray.opacity(0.6))
                                        Text("实体奖励")
                                            .font(.subheadline)
                                            .foregroundColor(.gray.opacity(0.8))
                                    }
                                )
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                    }
                    
                    // 内容描述
                    Text(reward.content)
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .lineSpacing(2)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.controlBackgroundColor))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
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
                if appState.unreadRewards.count > 1 {
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
                
                // 历史奖励按钮
                Button(action: {
                    dismiss()
                    // 跳转到历史奖励页面
                    appState.currentView = .rewardHistory
                }) {
                    Text("历史奖励")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                                .background(Color.clear)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
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
            // 没有奖励时的占位视图
            Text("暂无奖励")
                .foregroundColor(.secondary)
                .frame(width: 520, height: 640)
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
    
    private func markCurrentAsRead() {
        guard let reward = reward else { return }
        if let index = appState.unreadRewards.firstIndex(where: { $0.id == reward.id }) {
            appState.unreadRewards[index].isRead = true
        }
    }
    
    private func autoClaimCurrentReward() {
        guard let reward = reward else { return }
        // 自动将当前奖励添加到历史记录并从未读奖励中移除
        if let index = appState.unreadRewards.firstIndex(where: { $0.id == reward.id }) {
            let claimedReward = appState.unreadRewards[index]
            appState.allRewards.append(claimedReward)
            appState.unreadRewards.remove(at: index)
        }
        
        // 如果没有更多奖励了，3秒后自动关闭弹窗
        if appState.unreadRewards.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                dismiss()
            }
        }
    }
    
    private func showNextReward() {
        // 检查是否还有其他未读奖励
        if !appState.unreadRewards.isEmpty {
            // 有其他奖励，更新显示的奖励
            appState.currentRewardToShow = appState.unreadRewards.first
            appState.currentRewardIndex = 0
        } else {
            // 没有更多奖励，关闭弹窗
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