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
            // 编程技巧类奖励
            Reward(type: .programmingTip, title: "Cursor AI 编程技巧", content: "使用 Cursor 时，尝试编写更详细的注释，AI 会根据注释生成更准确的代码建议。保持注释简洁明了，描述代码的意图而不是实现细节。好的注释是与AI协作的关键。", imageName: nil),
            
            Reward(type: .programmingTip, title: "快捷键大师", content: "Cmd+D 快速选择相同文本，Cmd+Shift+L 选择所有相同文本，Cmd+Shift+K 删除整行，Option+↑/↓ 移动代码行，Cmd+/ 快速注释。掌握这些快捷键能让你的编码速度翻倍！", imageName: nil),
            
            Reward(type: .programmingTip, title: "Git 最佳实践", content: "每次提交都应该是一个完整的逻辑单元，避免把多个不相关的修改放在同一个提交中。写好的提交信息应该清楚地描述'为什么'而不仅仅是'做了什么'。使用 git rebase 保持提交历史的整洁。", imageName: nil),
            
            Reward(type: .programmingTip, title: "SwiftUI 性能优化", content: "使用 @StateObject 而不是 @ObservableObject 来避免不必要的视图重建。当视图的父组件重新创建时，@StateObject 会保持对象的生命周期。合理使用 @State、@Binding 和 @Published 能让你的 SwiftUI 应用更流畅。", imageName: nil),
            
            Reward(type: .programmingTip, title: "代码审查秘籍", content: "进行代码审查时，先关注架构和逻辑，再关注细节和格式。提出具体的改进建议而不是简单指出问题。记住代码审查的目的是提高代码质量和团队技能，而不是挑错。", imageName: nil),
            
            Reward(type: .programmingTip, title: "调试忍者技能", content: "使用 print() 和断点只是调试的基础。学会使用条件断点、日志断点和异常断点。在 Xcode 中善用 View Hierarchy 调试器和内存图调试器，能帮你快速定位复杂问题。", imageName: nil),
            
            Reward(type: .programmingTip, title: "API 设计哲学", content: "好的 API 设计应该直观易懂，难以误用。使用清晰的命名，保持接口的一致性，提供合理的默认值。记住：API 设计一旦发布就很难修改，所以前期设计要深思熟虑。", imageName: nil),
            
            // 实体奖励类
            Reward(type: .physicalReward, title: "精美编程贴纸套装", content: "恭喜获得限量版编程语言贴纸套装！包含Swift、Python、JavaScript、TypeScript、Rust、Go等12种热门语言的精美贴纸，每个都有独特的设计风格。让你的MacBook、显示器或桌面更加个性化！", imageName: nil),
            
            Reward(type: .physicalReward, title: "程序员专属键帽", content: "获得一个专为程序员设计的定制ESC键帽！采用双色注塑工艺，印有经典的 'sudo' 字样。兼容Cherry MX轴体，让你的机械键盘瞬间提升逼格！", imageName: nil),
            
            Reward(type: .physicalReward, title: "代码咖啡杯", content: "专属程序员马克杯来了！杯身印有经典代码片段和编程梗图，容量350ml，陶瓷材质，微波炉安全。喝咖啡的时候也能感受到代码的魅力！", imageName: nil),
            
            Reward(type: .physicalReward, title: "GitHub 纪念T恤", content: "限量版 GitHub 黑色纯棉T恤！正面是简洁的 Octocat 图案，背面印有你的 GitHub 用户名。100%纯棉材质，舒适透气，是程序员衣柜必备单品！", imageName: nil),
            
            Reward(type: .physicalReward, title: "RGB 机械键盘", content: "Cherry MX 红轴机械键盘！87键紧凑布局，RGB背光支持1680万色彩，Type-C接口，支持自定义宏编程。让你的代码输入体验更上一层楼！", imageName: nil),
            
            Reward(type: .physicalReward, title: "程序员鼠标垫", content: "超大尺寸编程主题鼠标垫！表面印有常用快捷键参考图，防滑底部，900x400mm的超大尺寸能容纳键盘和鼠标。再也不用担心快捷键记不住了！", imageName: nil)
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