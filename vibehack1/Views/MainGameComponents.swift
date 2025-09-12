//
//  MainGameComponents.swift
//  vibehack1
//
//  Created by Daniel on 2025/9/12.
//

import SwiftUI

struct TimerDisplayView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var timerManager: FocusTimerManager
    
    var body: some View {
        VStack(spacing: 8) {
            // 主计时显示
            Text(timerManager.formattedTime)
                .font(.system(size: 36, weight: .light, design: .monospaced))
                .foregroundColor(.primary)
            
            // 状态文字
            if appState.focusState != .idle {
                Text(statusText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // 进度指示条
            if appState.focusState != .idle {
                ProgressIndicatorView()
            }
        }
    }
    
    private var statusText: String {
        switch appState.focusState {
        case .idle:
            return ""
        case .focusing:
            return "已专注 \(formatTimeForStatus())"
        case .paused:
            return "暂停中 - 已专注 \(formatTimeForStatus())"
        }
    }
    
    private func formatTimeForStatus() -> String {
        let totalMinutes = Int(appState.currentFocusTime) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        if hours > 0 {
            return "\(hours)小时\(minutes)分钟"
        } else {
            return "\(minutes)分钟"
        }
    }
}

struct ProgressIndicatorView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(index < currentProgress ? Color.accentColor : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .scaleEffect(index < currentProgress ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: currentProgress)
            }
        }
    }
    
    private var currentProgress: Int {
        let minutes = Int(appState.currentFocusTime) / 60
        return min(minutes / 5, 8) // 每5分钟填充一个进度点
    }
}


struct ControlButtonsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var timerManager: FocusTimerManager
    @State private var isLongPressing = false
    @State private var longPressProgress: Double = 0.0
    @State private var longPressTimer: Timer?
    
    var body: some View {
        VStack(spacing: 12) {
            // 显示当前状态提示
            if appState.focusState == .idle {
                StatusIndicatorView()
            }
            
            HStack(spacing: 16) {
                switch appState.focusState {
                case .idle:
                    LongPressStartButton(
                        isEnabled: canStartFocus,
                        onLongPressComplete: {
                            timerManager.startFocus()
                        }
                    )
                    
                case .focusing:
                    Button("暂停") {
                        timerManager.pauseFocus()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    
                    Button("结束") {
                        timerManager.endFocus()
                    }
                    .buttonStyle(DestructiveButtonStyle())
                    
                case .paused:
                    Button("继续") {
                        timerManager.resumeFocus()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    
                    Button("结束") {
                        timerManager.endFocus()
                    }
                    .buttonStyle(DestructiveButtonStyle())
                }
            }
        }
    }
    
    private var canStartFocus: Bool {
        return appState.shrineOccupiedTarget != nil
    }
}

struct StatusIndicatorView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(spacing: 16) {
            // 祈福对象状态
            HStack(spacing: 4) {
                Image(systemName: appState.shrineOccupiedTarget != nil ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(appState.shrineOccupiedTarget != nil ? .green : .gray)
                Text("祈福对象")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
        }
        .padding(.vertical, 4)
    }
}


struct RewardAreaView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Button {
            appState.currentView = .rewardDetail
        } label: {
            HStack {
                Image(systemName: "gift.fill")
                    .foregroundColor(.orange)
                
                if appState.unreadRewards.isEmpty {
                    Text("暂无锦囊")
                        .foregroundColor(.secondary)
                } else {
                    VStack(alignment: .leading) {
                        Text("🎁 锦囊区域")
                            .foregroundColor(.primary)
                        Text("点击查看 \(appState.unreadRewards.count) 个新锦囊")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    
                    if !appState.unreadRewards.isEmpty {
                        Text("NEW")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .cornerRadius(4)
                            .scaleEffect(1.2)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: UUID())
                    }
                }
                
                Spacer()
            }
            .padding()
            .frame(height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.controlBackgroundColor))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// 按钮样式
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.gray)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct DestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - 长按开始按钮
struct LongPressStartButton: View {
    let isEnabled: Bool
    let onLongPressComplete: () -> Void
    
    @State private var isLongPressing = false
    @State private var longPressProgress: Double = 0.0
    @State private var longPressTimer: Timer?
    
    private let longPressDuration: Double = 5.0
    private let timerInterval: Double = 0.05
    
    var body: some View {
        ZStack {
            // 背景进度环
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                .frame(width: 60, height: 60)
            
            // 进度环
            Circle()
                .trim(from: 0, to: longPressProgress)
                .stroke(Color.accentColor, lineWidth: 4)
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: timerInterval), value: longPressProgress)
            
            // 按钮内容
            VStack(spacing: 2) {
                if isLongPressing {
                    Text("长按中")
                        .font(.caption2)
                        .foregroundColor(.primary)
                    Text(String(format: "%.1f", (longPressDuration - longPressProgress * longPressDuration)))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .monospacedDigit()
                } else {
                    Image(systemName: "flame.fill")
                        .font(.title3)
                        .foregroundColor(isEnabled ? .accentColor : .gray)
                    Text("上香")
                        .font(.caption2)
                        .foregroundColor(isEnabled ? .primary : .secondary)
                }
            }
        }
        .scaleEffect(isLongPressing ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isLongPressing)
        .disabled(!isEnabled)
        .onLongPressGesture(
            minimumDuration: longPressDuration,
            maximumDistance: 50,
            pressing: { pressing in
                if pressing && isEnabled {
                    startLongPress()
                } else {
                    cancelLongPress()
                }
            },
            perform: {
                completeLongPress()
            }
        )
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in
            cancelLongPress()
        }
        .focusable()
        .onKeyPress(.space, phases: .down) { _ in
            if isEnabled && !isLongPressing {
                startLongPress()
                return .handled
            }
            return .ignored
        }
        .onKeyPress(.space, phases: .up) { _ in
            if isLongPressing {
                cancelLongPress()
                return .handled
            }
            return .ignored
        }
    }
    
    private func startLongPress() {
        guard !isLongPressing else { return }
        
        isLongPressing = true
        longPressProgress = 0.0
        
        longPressTimer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { _ in
            longPressProgress += timerInterval / longPressDuration
            
            if longPressProgress >= 1.0 {
                longPressProgress = 1.0
                cancelLongPress()
            }
        }
    }
    
    private func cancelLongPress() {
        isLongPressing = false
        longPressProgress = 0.0
        longPressTimer?.invalidate()
        longPressTimer = nil
    }
    
    private func completeLongPress() {
        cancelLongPress()
        onLongPressComplete()
    }
}