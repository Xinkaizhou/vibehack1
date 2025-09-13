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
        
        // 刚点燃蜡烛时，90%概率掉落编程技巧奖励
        if Double.random(in: 0...1) < 0.9 {
            dropReward(guaranteed: false, rewardType: .programmingTip)
            print("点燃蜡烛获得福报！")
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
        
        // 祈福结束时100%掉落实体奖励
        dropReward(guaranteed: true, rewardType: .physicalReward)
        
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
        // 30%概率掉落编程技巧奖励
        if Double.random(in: 0...1) < 0.3 {
            dropReward(guaranteed: false, rewardType: .programmingTip)
        }
    }
    
    private func dropReward(guaranteed: Bool, rewardType: Reward.RewardType? = nil) {
        let reward: Reward
        if let specificType = rewardType {
            reward = generateSpecificReward(type: specificType)
        } else {
            reward = generateRandomReward()
        }
        appState.unreadRewards.append(reward)
    }
    
    private func generateRandomReward() -> Reward {
        // 实体奖励池 - 占更高比重
        let physicalRewards = [
            Reward(type: .physicalReward, title: "疯狂星期四主持权", content: "恭喜获得疯狂星期四主持权一天！你将成为群里最靓的仔，带领大家开启欢乐的星期四时光。记得准备好段子和表情包，让这一天充满快乐和笑声！", imageName: "vibefriends"),
            
            Reward(type: .physicalReward, title: "PPT.AI专业版月卡", content: "获得PPT.AI专业版会员一个月！解锁全部高级模板和AI功能，让你的演示文稿制作效率提升10倍。无论是工作汇报还是学术展示，都能轻松搞定！", imageName: "pptai"),
            
            Reward(type: .physicalReward, title: "ZenMux 20美金额度", content: "恭喜获得ZenMux平台20美金使用额度！可以用于购买各种数字工具和服务，提升你的工作效率。合理使用这笔资金，让它为你创造更大的价值！", imageName: "zenmux"),
            
            Reward(type: .physicalReward, title: "Kiro工具会员月卡", content: "获得Kiro工具平台会员资格一个月！解锁全部高级功能和工具集，让你的开发工作更加高效便捷。探索各种实用工具，发现新的工作流程！", imageName: "kiro")
        ]
        
        // AI编程技巧池
        let programmingTips = [
            Reward(type: .programmingTip, title: "Cursor智能补全秘籍", content: "Tab键接受AI建议，Cmd+K调出智能对话，@符号引用特定文件上下文。使用Cursor时，编写清晰的注释能让AI生成更精确的代码。善用这些快捷键，让AI成为你最强的编程搭档！", imageName: nil),
            
            Reward(type: .programmingTip, title: "Claude编程提示工程", content: "使用结构化提示：'作为[角色]，帮我[任务]，要求[条件]'。将复杂功能拆解为小步骤，让AI逐步实现能大幅提高代码质量。合理控制上下文信息，避免AI信息过载。", imageName: nil),
            
            Reward(type: .programmingTip, title: "AI调试神技", content: "让AI自动分析错误信息：复制完整的错误堆栈，包含相关代码上下文，AI能快速定位问题并提供修复方案。比传统调试快10倍！", imageName: nil),
            
            Reward(type: .programmingTip, title: "Git 提交艺术", content: "每次提交都应该是一个完整的逻辑单元，避免把多个不相关的修改放在同一个提交中。写好的提交信息应该清楚地描述'为什么'而不仅仅是'做了什么'。使用 git rebase 保持提交历史的整洁。", imageName: nil),
            
            Reward(type: .programmingTip, title: "SwiftUI 性能优化", content: "使用 @StateObject 而不是 @ObservableObject 来避免不必要的视图重建。当视图的父组件重新创建时，@StateObject 会保持对象的生命周期。合理使用 @State、@Binding 和 @Published 能让你的 SwiftUI 应用更流畅。", imageName: nil),
            
            Reward(type: .programmingTip, title: "代码审查高手", content: "进行代码审查时，先关注架构和逻辑，再关注细节和格式。提出具体的改进建议而不是简单指出问题。记住代码审查的目的是提高代码质量和团队技能，而不是挑错。", imageName: nil),
            
            Reward(type: .programmingTip, title: "API 设计哲学", content: "好的 API 设计应该直观易懂，难以误用。使用清晰的命名，保持接口的一致性，提供合理的默认值。记住：API 设计一旦发布就很难修改，所以前期设计要深思熟虑。", imageName: nil),
            
            Reward(type: .programmingTip, title: "迭代式AI协作", content: "与AI协作开发时，采用小步快跑策略：先实现核心功能，再逐步完善细节。每次迭代都要测试验证，这样能确保代码质量和项目进度。", imageName: nil)
        ]
        
        // 70%概率获得实体奖励，30%概率获得编程技巧
        if Double.random(in: 0...1) < 0.7 {
            return physicalRewards.randomElement()!
        } else {
            return programmingTips.randomElement()!
        }
    }
    
    private func generateSpecificReward(type: Reward.RewardType) -> Reward {
        // 实体奖励池
        let physicalRewards = [
            Reward(type: .physicalReward, title: "疯狂星期四主持权", content: "恭喜获得疯狂星期四主持权一天！你将成为群里最靓的仔，带领大家开启欢乐的星期四时光。记得准备好段子和表情包，让这一天充满快乐和笑声！", imageName: "vibefriends"),
            
            Reward(type: .physicalReward, title: "PPT.AI专业版月卡", content: "获得PPT.AI专业版会员一个月！解锁全部高级模板和AI功能，让你的演示文稿制作效率提升10倍。无论是工作汇报还是学术展示，都能轻松搞定！", imageName: "pptai"),
            
            Reward(type: .physicalReward, title: "ZenMux 20美金额度", content: "恭喜获得ZenMux平台20美金使用额度！可以用于购买各种数字工具和服务，提升你的工作效率。合理使用这笔资金，让它为你创造更大的价值！", imageName: "zenmux"),
            
            Reward(type: .physicalReward, title: "Kiro工具会员月卡", content: "获得Kiro工具平台会员资格一个月！解锁全部高级功能和工具集，让你的开发工作更加高效便捷。探索各种实用工具，发现新的工作流程！", imageName: "kiro")
        ]
        
        // AI编程技巧池
        let programmingTips = [
            Reward(type: .programmingTip, title: "Cursor智能补全秘籍", content: "Tab键接受AI建议，Cmd+K调出智能对话，@符号引用特定文件上下文。使用Cursor时，编写清晰的注释能让AI生成更精确的代码。善用这些快捷键，让AI成为你最强的编程搭档！", imageName: nil),
            
            Reward(type: .programmingTip, title: "Claude编程提示工程", content: "使用结构化提示：'作为[角色]，帮我[任务]，要求[条件]'。将复杂功能拆解为小步骤，让AI逐步实现能大幅提高代码质量。合理控制上下文信息，避免AI信息过载。", imageName: nil),
            
            Reward(type: .programmingTip, title: "AI调试神技", content: "让AI自动分析错误信息：复制完整的错误堆栈，包含相关代码上下文，AI能快速定位问题并提供修复方案。比传统调试快10倍！", imageName: nil),
            
            Reward(type: .programmingTip, title: "Git 提交艺术", content: "每次提交都应该是一个完整的逻辑单元，避免把多个不相关的修改放在同一个提交中。写好的提交信息应该清楚地描述'为什么'而不仅仅是'做了什么'。使用 git rebase 保持提交历史的整洁。", imageName: nil),
            
            Reward(type: .programmingTip, title: "SwiftUI 性能优化", content: "使用 @StateObject 而不是 @ObservableObject 来避免不必要的视图重建。当视图的父组件重新创建时，@StateObject 会保持对象的生命周期。合理使用 @State、@Binding 和 @Published 能让你的 SwiftUI 应用更流畅。", imageName: nil),
            
            Reward(type: .programmingTip, title: "代码审查高手", content: "进行代码审查时，先关注架构和逻辑，再关注细节和格式。提出具体的改进建议而不是简单指出问题。记住代码审查的目的是提高代码质量和团队技能，而不是挑错。", imageName: nil),
            
            Reward(type: .programmingTip, title: "API 设计哲学", content: "好的 API 设计应该直观易懂，难以误用。使用清晰的命名，保持接口的一致性，提供合理的默认值。记住：API 设计一旦发布就很难修改，所以前期设计要深思熟虑。", imageName: nil),
            
            Reward(type: .programmingTip, title: "迭代式AI协作", content: "与AI协作开发时，采用小步快跑策略：先实现核心功能，再逐步完善细节。每次迭代都要测试验证，这样能确保代码质量和项目进度。", imageName: nil)
        ]
        
        switch type {
        case .physicalReward:
            return physicalRewards.randomElement()!
        case .programmingTip:
            return programmingTips.randomElement()!
        }
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