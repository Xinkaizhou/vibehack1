//
//  StandardSelectionSheet.swift
//  vibehack1
//
//  Created by Daniel on 2025/9/13.
//

import SwiftUI

// MARK: - 标准选择弹窗
struct StandardSelectionSheet: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var timerManager: FocusTimerManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTarget: PrayTarget?
    
    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部标题栏
            ZStack {
                // 标题居中
                Text("选择码神")
                    .font(.title2)
                    .fontWeight(.semibold)
                
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
                LazyVGrid(columns: columns, spacing: 32) {
                    ForEach(PrayTarget.presetTargets, id: \.id) { target in
                        StandardSelectionItem(
                            target: target,
                            isSelected: selectedTarget?.id == target.id,
                            onTap: {
                                selectedTarget = target
                            }
                        )
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 24)
                .padding(.bottom, 120) // 为底部按钮留空间
            }
            .background(Color(.windowBackgroundColor))
            
            // 底部按钮区域
            VStack(spacing: 12) {
                // 确认选择按钮
                Button(action: {
                    if let target = selectedTarget {
                        let previousTarget = appState.shrineOccupiedTarget
                        appState.shrineOccupiedTarget = target
                        
                        // 如果选择了不同的对象，切换背景
                        if previousTarget?.id != target.id {
                            appState.updateBackgroundForTarget(target)
                        }
                        
                        // 推进引导步骤
                        if appState.isFirstTimeUser && appState.onboardingStep == .welcome {
                            appState.advanceOnboardingStep()
                        }
                        
                        dismiss()
                    }
                }) {
                    Text("确认选择")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            selectedTarget != nil ? 
                            LinearGradient(colors: [Color.blue, Color.blue.opacity(0.8)], startPoint: .top, endPoint: .bottom) :
                            LinearGradient(colors: [Color.gray.opacity(0.6), Color.gray.opacity(0.4)], startPoint: .top, endPoint: .bottom)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(selectedTarget == nil)
                .buttonStyle(.plain)
                
                // 清空选择并返回按钮
                Button(action: {
                    // 如果正在祈福，先结束祈福
                    if appState.focusState == .focusing {
                        timerManager.endFocus()
                    } else {
                        // 清空选择并重置背景
                        appState.shrineOccupiedTarget = nil
                        appState.updateBackgroundForTarget(nil)
                    }
                    dismiss()
                }) {
                    Text("清空选择并返回")
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
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 24)
            .background(Color(.windowBackgroundColor))
        }
        .frame(width: 520, height: 640) // 稍微放大弹窗
        .background(Color(.windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 8)
        .onAppear {
            selectedTarget = appState.shrineOccupiedTarget
        }
    }
}

// MARK: - 标准选择项
struct StandardSelectionItem: View {
    let target: PrayTarget
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                // 应用图标容器
                ZStack {
                    // 现在所有图标都是Assets中的图片资源 - 直接显示
                    Image(target.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit) // ✅ 保持原始比例，不裁剪
                        .frame(maxWidth: 80, maxHeight: 80) // ✅ 最大尺寸约束，不强制变形
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            // 选中状态的边框 - 覆盖整个可视区域
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    isSelected ? Color.blue : Color.clear,
                                    lineWidth: 3
                                )
                                .frame(maxWidth: 80, maxHeight: 80)
                        )
                        .shadow(color: isSelected ? .blue.opacity(0.4) : Color.black.opacity(0.1), radius: isSelected ? 8 : 2)
                }
                .frame(width: 100, height: 100) // 统一容器大小
                
                // 应用名称
                Text(target.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(isSelected ? .blue : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    StandardSelectionSheet()
        .environmentObject(AppState())
}