//
//  FocusTimerManager.swift
//  vibehack1
//
//  Created by Daniel on 2025/9/12.
//

import Foundation
import Combine

class FocusTimerManager: ObservableObject {
    private var timer: Timer?
    private var rewardCheckTimer: Timer?
    private let appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    func startFocus() {
        guard appState.focusState == .idle,
              appState.shrineOccupiedTarget != nil else { 
            print("Cannot start focus: missing shrine target")
            return 
        }
        
        appState.focusState = .focusing
        appState.currentFocusTime = 0
        
        // 完成新用户引导
        if appState.isFirstTimeUser && appState.onboardingStep == .targetSelected {
            appState.completeOnboarding()
        }
        
        // 启动主计时器 - 每秒更新，无限计时
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateFocusTime()
            }
        }
        // 确保 Timer 在所有 RunLoop mode 下都能运行，包括窗口隐藏时
        RunLoop.main.add(timer!, forMode: .common)
        
        // 启动福报奖励检查计时器 - 每5分钟检查
        startRewardCheckTimer()
    }
    
    func pauseFocus() {
        guard appState.focusState == .focusing else { return }
        
        appState.focusState = .paused
        timer?.invalidate()
        timer = nil
        rewardCheckTimer?.invalidate()
        rewardCheckTimer = nil
    }
    
    func resumeFocus() {
        guard appState.focusState == .paused else { return }
        
        appState.focusState = .focusing
        
        // 重新启动计时器
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateFocusTime()
            }
        }
        // 确保 Timer 在所有 RunLoop mode 下都能运行
        RunLoop.main.add(timer!, forMode: .common)
        
        startRewardCheckTimer()
    }
    
    func endFocus() {
        timer?.invalidate()
        timer = nil
        rewardCheckTimer?.invalidate()
        rewardCheckTimer = nil
        
        // 祈福结束时100%掉落福报奖励
        dropReward(guaranteed: true)
        
        // 增加今日祈福次数统计
        appState.todayIncenseCount += 1
        
        // 重置状态
        appState.focusState = .idle
        appState.currentFocusTime = 0
        appState.selectedPrayTarget = nil
        
        // 清理祈福区域
        appState.shrineOccupiedTarget = nil
        
        // 重置背景为首页
        appState.updateBackgroundForTarget(nil)
    }
    
    private func updateFocusTime() {
        appState.currentFocusTime += 1
        // 无限计时，不自动结束
    }
    
    private func startRewardCheckTimer() {
        // 每5分钟检查一次福报奖励掉落
        rewardCheckTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.checkRewardDrop()
        }
        // 确保奖励计时器也能在所有 RunLoop mode 下运行
        if let rewardTimer = rewardCheckTimer {
            RunLoop.main.add(rewardTimer, forMode: .common)
        }
    }
    
    private func checkRewardDrop() {
        // 30%概率掉落福报奖励
        if Double.random(in: 0...1) < 0.3 {
            dropReward(guaranteed: false)
        }
    }
    
    private func dropReward(guaranteed: Bool) {
        let reward = generateRandomReward()
        appState.unreadRewards.append(reward)
    }
    
    private func generateRandomReward() -> Reward {
        let rewardPool = [
            Reward(type: .programmingTip, title: "编程小贴士", content: "使用 Cursor 时，尝试编写更详细的注释，AI 会根据注释生成更准确的代码建议。", rarity: .common),
            Reward(type: .programmingTip, title: "快捷键技巧", content: "Cmd+D 可以快速选择相同的文本，Cmd+Shift+L 可以选择所有相同文本。", rarity: .common),
            Reward(type: .motivation, title: "专注祝贺", content: "恭喜完成一段专注时光！持续的专注是通向成功的阶梯。", rarity: .rare),
            Reward(type: .blessing, title: "代码祝福", content: "愿你的代码如诗如画，愿你的逻辑清晰明了，愿你的bug越来越少。", rarity: .epic),
            Reward(type: .programmingTip, title: "AI编程建议", content: "与AI协作时，描述你的意图比直接要求代码更有效。告诉AI你要解决的问题，而不是如何解决。", rarity: .rare)
        ]
        
        return rewardPool.randomElement()!
    }
    
    // 格式化显示时间
    var formattedTime: String {
        let totalSeconds = Int(appState.currentFocusTime)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    // 菜单栏显示格式
    var menuBarFormattedTime: String {
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