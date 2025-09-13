//
//  RewardHistoryView.swift
//  vibehack1
//
//  Created by Daniel on 2025/9/13.
//

import SwiftUI

struct RewardHistoryView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部导航栏
            HStack {
                Button(action: {
                    appState.currentView = .main
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                        Text("返回")
                    }
                    .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                
                Spacer()
                
                Text("历史奖励")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // 占位空间保持对称
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                    Text("返回")
                }
                .opacity(0)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(Color(.windowBackgroundColor))
            .overlay(
                Rectangle()
                    .fill(Color.black.opacity(0.1))
                    .frame(height: 1),
                alignment: .bottom
            )
            
            // 奖励列表
            if sortedRewards.isEmpty {
                // 空状态
                VStack(spacing: 20) {
                    Image(systemName: "gift")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("暂无历史奖励")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Text("完成祈福后会获得福报奖励")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.windowBackgroundColor))
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(sortedRewards, id: \.id) { reward in
                            RewardHistoryItem(reward: reward)
                            
                            if reward.id != sortedRewards.last?.id {
                                Divider()
                                    .padding(.leading, 80)
                            }
                        }
                    }
                    .padding(.top, 8)
                }
                .background(Color(.windowBackgroundColor))
            }
        }
        .background(Color(.windowBackgroundColor))
    }
    
    // 按时间倒序排列的奖励
    private var sortedRewards: [Reward] {
        appState.allRewards.sorted { $0.timestamp > $1.timestamp }
    }
}

struct RewardHistoryItem: View {
    let reward: Reward
    
    var body: some View {
        HStack(spacing: 16) {
            // 奖励类型图标
            ZStack {
                Circle()
                    .fill(reward.type == .physicalReward ? Color.green.opacity(0.1) : Color.blue.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: reward.type == .physicalReward ? "gift.fill" : "lightbulb.fill")
                    .font(.system(size: 20))
                    .foregroundColor(reward.type == .physicalReward ? .green : .blue)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                // 标题
                Text(reward.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                // 内容预览
                Text(reward.content)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // 时间和类型
                HStack {
                    Text(formattedDate(reward.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(reward.type == .physicalReward ? "实体奖励" : "编程技巧")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(reward.type == .physicalReward ? Color.green.opacity(0.2) : Color.blue.opacity(0.2))
                        )
                        .foregroundColor(reward.type == .physicalReward ? .green : .blue)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
        .onTapGesture {
            // 点击可以查看详情或其他操作
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDate(date, inSameDayAs: Date()) {
            formatter.timeStyle = .short
            return "今天 " + formatter.string(from: date)
        } else if calendar.isDate(date, inSameDayAs: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()) {
            formatter.timeStyle = .short
            return "昨天 " + formatter.string(from: date)
        } else {
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            formatter.locale = Locale(identifier: "zh_CN")
            return formatter.string(from: date)
        }
    }
}

#Preview {
    let appState = AppState()
    
    // 添加测试数据
    appState.allRewards = [
        Reward(type: .physicalReward, title: "精美编程贴纸", content: "获得了一套精美的编程语言贴纸，包含Swift、Python、JavaScript等多种语言的可爱贴纸。", imageName: nil),
        Reward(type: .programmingTip, title: "SwiftUI性能优化", content: "使用 @StateObject 而不是 @ObservableObject 来避免不必要的视图重建。当视图的父组件重新创建时，@StateObject 会保持对象的生命周期。", imageName: nil),
        Reward(type: .physicalReward, title: "定制键帽", content: "专为程序员设计的定制键帽，让你的键盘更加个性化。", imageName: nil),
        Reward(type: .programmingTip, title: "Git最佳实践", content: "每次提交都应该是一个完整的逻辑单元，避免把多个不相关的修改放在同一个提交中。好的提交信息应该清楚地描述'为什么'而不仅仅是'做了什么'。", imageName: nil)
    ]
    
    return RewardHistoryView()
        .environmentObject(appState)
        .frame(width: 650, height: 850)
}