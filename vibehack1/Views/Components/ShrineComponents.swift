//
//  ShrineComponents.swift
//  vibehack1
//
//  Created by Daniel on 2025/9/12.
//

import SwiftUI

// MARK: - 牌坊展示区域
struct ShrineDisplayView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingPrayTargetSelection = false
    
    var body: some View {
        VStack(spacing: 12) {
            // 牌坊装饰顶部
            HStack(spacing: 4) {
                ForEach(0..<7, id: \.self) { _ in
                    Rectangle()
                        .frame(width: 12, height: 4)
                        .foregroundColor(.brown)
                }
            }
            
            // 牌坊主体区域
            Button(action: {
                showingPrayTargetSelection = true
            }) {
                ZStack {
                    // 牌坊背景
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.brown.opacity(0.15),
                                    Color.brown.opacity(0.25),
                                    Color.brown.opacity(0.4)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.brown.opacity(0.6), Color.brown],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 3
                                )
                        )
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    
                    // 显示内容
                    if let occupiedTarget = appState.shrineOccupiedTarget {
                        // 显示已选择的祈福对象
                        OccupiedShrineView(target: occupiedTarget)
                    } else {
                        // 空白状态 - 提示点击选择
                        VStack(spacing: 12) {
                            Image(systemName: "hand.tap.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.brown.opacity(0.6))
                            
                            Text("点击选择码神")
                                .font(.headline)
                                .foregroundColor(.brown)
                        }
                    }
                }
            }
            .buttonStyle(.plain)
            .frame(height: 280)
            
        }
        .sheet(isPresented: $showingPrayTargetSelection) {
            PrayTargetSelectionSheet()
        }
    }
}

struct EmptyShrineView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "flame")
                .font(.system(size: 30))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("将祈福对象拖拽到此处")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct OccupiedShrineView: View {
    let target: PrayTarget
    
    var body: some View {
        VStack(spacing: 12) {
            Image(target.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)  // 比原来大5倍
                .background(
                    Circle()
                        .fill(Color.white)
                        .frame(width: 220, height: 220)
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                )
            
            Text(target.name)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .scaleEffect(1.1)
        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: UUID())
    }
}



// MARK: - 福报奖励列表区域
struct RewardListView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "gift.fill")
                    .foregroundColor(.pink)
                    .font(.caption)
                Text("福报奖励")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                Spacer()
                if !appState.unreadRewards.isEmpty {
                    Text("\(appState.unreadRewards.count)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .clipShape(Capsule())
                }
            }
            
            if appState.unreadRewards.isEmpty {
                EmptyRewardListView()
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(appState.unreadRewards) { reward in
                            RewardListItem(reward: reward)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .frame(height: 160)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.controlBackgroundColor))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
    }
}

struct EmptyRewardListView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "gift")
                .font(.title3)
                .foregroundColor(.gray.opacity(0.5))
            
            Text("暂无福报奖励")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.controlBackgroundColor).opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
                )
        )
    }
}

struct RewardListItem: View {
    let reward: Reward
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(spacing: 8) {
            // 福报奖励图标
            Image(systemName: rewardIcon)
                .font(.caption)
                .foregroundColor(reward.type == .physicalReward ? .green : .blue)
                .frame(width: 16)
            
            // 福报奖励标题
            Text(reward.title)
                .font(.caption2)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Spacer()
            
            // 新福报奖励标识
            if !reward.isRead {
                Circle()
                    .fill(Color.red)
                    .frame(width: 6, height: 6)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(.controlBackgroundColor))
        )
        .onTapGesture {
            appState.currentView = .rewardDetail
        }
    }
    
    private var rewardIcon: String {
        switch reward.type {
        case .physicalReward:
            return "gift.fill"
        case .programmingTip:
            return "lightbulb.fill"
        }
    }
}

// MARK: - 冒烟效果
struct SmokeEffectView: View {
    @State private var smokeOffset: CGFloat = 0
    @State private var smokeOpacity: Double = 0.6
    
    var body: some View {
        VStack(spacing: 2) {
            // 多层烟雾效果
            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .fill(Color.gray.opacity(smokeOpacity))
                    .frame(width: CGFloat(4 + index * 2), height: CGFloat(4 + index * 2))
                    .offset(x: sin(smokeOffset + Double(index) * 0.5) * 5, 
                           y: -CGFloat(index * 8))
                    .opacity(smokeOpacity - Double(index) * 0.15)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                smokeOffset = .pi * 2
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                smokeOpacity = 0.2
            }
        }
    }
}

#Preview {
    let appState = AppState()
    
    HStack(spacing: 20) {
        VStack {
            ShrineDisplayView()
        }
        
        RewardListView()
    }
    .environmentObject(appState)
    .padding()
    .frame(width: 500, height: 300)
}