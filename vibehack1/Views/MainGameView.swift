//
//  MainGameView.swift
//  vibehack1
//
//  Created by Daniel on 2025/9/12.
//

import SwiftUI

struct MainGameView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var timerManager: FocusTimerManager
    @State private var onlineCount = Int.random(in: 800...2000)
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部信息栏 - 根据引导状态切换
            Group {
                if appState.isFirstTimeUser && appState.onboardingStep != .completed {
                    OnboardingInfoBar()
                } else {
                    NormalInfoBar(timerManager: timerManager, onlineCount: onlineCount)
                }
            }
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.easeInOut(duration: 0.6), value: appState.isFirstTimeUser)
            .animation(.easeInOut(duration: 0.6), value: appState.onboardingStep)
            
            // 下方祭坛功能区域 - 保留所有功能，只移除背景图片
            ZStack {
                // 祭坛背景图片
                Image(appState.currentBackgroundImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .transition(.opacity.combined(with: .scale(scale: 1.05)))
                    .animation(.easeInOut(duration: 0.6), value: appState.currentBackgroundImage)
                
                // 祭坛功能内容
                VStack(spacing: 0) {
                    // 上部分：祈福对象区域
                    VStack {
                        Spacer()
                            .frame(height: 80)  // 增加顶部间距，让祈福对象更靠下
                        CentralAltarArea()
                        Spacer()
                            .frame(height: 20)  // 减少底部间距
                    }
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    
                    // 中部分：空间分隔
                    Spacer()
                        .frame(height: 15)  // 再减少5px，让蜡烛更高
                    
                    // 下部分：蜡烛区域
                    VStack {
                        HStack(spacing: 80) {
                            TraditionalCandleView(position: .left)
                            TraditionalCandleView(position: .right)
                        }
                        .frame(maxWidth: .infinity)
                        Spacer()
                            .frame(height: 40)
                    }
                    .frame(height: 160)  // 增加蜡烛区域高度
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                
                // 移除这里的烟雾，使用原有的 AltarAmbienceSmoke
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $appState.isShowingRewardSheet) {
            RewardSheet()
        }
    }
    
    private var statusText: String {
        switch appState.focusState {
        case .idle:
            return ""
        case .focusing:
            return "专注中..."
        case .paused:
            return "已暂停"
        }
    }
    
    private var todayFocusCount: Int {
        return appState.todayIncenseCount
    }
}


// MARK: - 顶部信息栏
struct TopInfoBar: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var timerManager: FocusTimerManager
    @State private var onlineCount = Int.random(in: 800...2000)
    
    var body: some View {
        HStack(spacing: 24) {
            // 计时显示
            VStack(spacing: 2) {
                Text(timerManager.formattedTime)
                    .font(.system(size: 20, weight: .medium, design: .monospaced))
                    .foregroundColor(.black)
                
                if appState.focusState != .idle {
                    Text(statusText)
                        .font(.caption2)
                        .foregroundColor(.black.opacity(0.7))
                }
            }
            
            Divider()
                .frame(height: 50)
            
            // 上香统计
            VStack(spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    Text("今日上香")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                }
                
                Text("第 \(todayFocusCount) 次")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
            
            Divider()
                .frame(height: 50)
            
            // 在线人数
            VStack(spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                    Text("在线点香者")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                }
                
                Text("\(onlineCount) 人")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
            }
            
            Divider()
                .frame(height: 50)
            
            // 福报池
            VStack(spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "gift.fill")
                        .foregroundColor(.pink)
                        .font(.caption)
                    Text("福报池")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                }
                
                if appState.unreadRewards.isEmpty {
                    Text("暂无福报")
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.6))
                } else {
                    Button(action: {
                        appState.currentView = .rewardDetail
                    }) {
                        Text("福报奖励 x\(appState.unreadRewards.count)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.pink)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .onAppear {
            // 定期更新在线人数
            Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 1.0)) {
                    onlineCount = Int.random(in: 800...2000)
                }
            }
        }
    }
    
    private var statusText: String {
        switch appState.focusState {
        case .idle:
            return ""
        case .focusing:
            return "专注中..."
        case .paused:
            return "已暂停"
        }
    }
    
    private var todayFocusCount: Int {
        return appState.todayIncenseCount
    }
}

// MARK: - 右侧信息面板（旧版本，保留以防需要）
struct RightInfoPanel: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var timerManager: FocusTimerManager
    @State private var onlineCount = Int.random(in: 800...2000)
    
    var body: some View {
        VStack(spacing: 16) {
            // 计时显示
            VStack(spacing: 4) {
                Text(timerManager.formattedTime)
                    .font(.system(size: 24, weight: .medium, design: .monospaced))
                    .foregroundColor(.black)
                
                if appState.focusState != .idle {
                    Text(statusText)
                        .font(.caption2)
                        .foregroundColor(.black.opacity(0.7))
                }
            }
            .padding(.vertical, 8)
            
            Divider()
            
            // 上香统计
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    Text("今日上香")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                    Spacer()
                }
                
                Text("第 \(todayFocusCount) 次")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
            
            Divider()
            
            // 在线人数
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                    Text("在线点香者")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                    Spacer()
                }
                
                Text("\(onlineCount) 人")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
            }
            
            Divider()
            
            // 福报池
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "gift.fill")
                        .foregroundColor(.pink)
                        .font(.caption)
                    Text("福报池")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                    Spacer()
                }
                
                if appState.unreadRewards.isEmpty {
                    Text("暂无福报")
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.6))
                } else {
                    Button(action: {
                        appState.currentView = .rewardDetail
                    }) {
                        Text("福报奖励 x\(appState.unreadRewards.count)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.pink)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .onAppear {
            // 定期更新在线人数
            Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 1.0)) {
                    onlineCount = Int.random(in: 800...2000)
                }
            }
        }
    }
    
    private var statusText: String {
        switch appState.focusState {
        case .idle:
            return ""
        case .focusing:
            return "专注中..."
        case .paused:
            return "已暂停"
        }
    }
    
    private var todayFocusCount: Int {
        return appState.todayIncenseCount
    }
}

struct CommunityInfoView: View {
    @State private var onlineCount = Int.random(in: 800...2000)
    
    var body: some View {
        HStack {
            Image(systemName: "flame.fill")
                .foregroundColor(.orange)
            Text("\(onlineCount) 位开发者在线专注")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
        .onAppear {
            // 定期更新在线人数
            Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 1.0)) {
                    onlineCount = Int.random(in: 800...2000)
                }
            }
        }
    }
}

struct PrayTargetSelectionView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 12) {
            Text("选择码神")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(PrayTarget.presetTargets, id: \.id) { target in
                    PrayTargetCard(target: target)
                }
            }
        }
    }
}

struct PrayTargetCard: View {
    let target: PrayTarget
    @EnvironmentObject var appState: AppState
    
    private var isSelected: Bool {
        appState.selectedPrayTarget?.id == target.id
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: target.icon)
                .font(.title2)
                .foregroundColor(isSelected ? .white : .primary)
            
            Text(target.name)
                .font(.caption)
                .foregroundColor(isSelected ? .white : .primary)
        }
        .frame(width: 80, height: 60)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.accentColor : Color(.controlBackgroundColor))
                .shadow(color: .black.opacity(0.1), radius: isSelected ? 8 : 2, x: 0, y: isSelected ? 4 : 1)
        )
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .onTapGesture {
            appState.selectedPrayTarget = target
        }
        .disabled(appState.focusState != .idle)
    }
}

struct IncenseBurnerView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 16) {
            // 香炉图标
            ZStack {
                Circle()
                    .fill(burnerColor)
                    .frame(width: 120, height: 120)
                    .scaleEffect(appState.focusState == .focusing ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), 
                              value: appState.focusState == .focusing)
                
                Image(systemName: burnerIcon)
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                
                // 祈福对象悬浮显示
                if let target = appState.selectedPrayTarget, appState.focusState != .idle {
                    Image(systemName: target.icon)
                        .font(.title3)
                        .foregroundColor(.white)
                        .offset(y: -60)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: UUID())
                }
            }
            
            // 祝福语显示
            if let target = appState.selectedPrayTarget {
                VStack(spacing: 4) {
                    Text("为 \(target.name) 祈福")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    private var burnerIcon: String {
        switch appState.focusState {
        case .idle:
            return "flame"
        case .focusing:
            return "flame.fill"
        case .paused:
            return "pause.fill"
        }
    }
    
    private var burnerColor: Color {
        switch appState.focusState {
        case .idle:
            return .gray
        case .focusing:
            return .orange
        case .paused:
            return .blue
        }
    }
}

#Preview {
    let appState = AppState()
    let timerManager = FocusTimerManager(appState: appState)
    
    MainGameView()
        .environmentObject(appState)
        .environmentObject(timerManager)
        .frame(width: 400, height: 600)
}
