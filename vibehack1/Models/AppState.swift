//
//  AppState.swift
//  vibehack1
//
//  Created by Daniel on 2025/9/12.
//

import SwiftUI
import Foundation
import Combine

class AppState: ObservableObject {
    @Published var currentView: ViewType = .main
    @Published var focusState: FocusState = .idle
    @Published var selectedPrayTarget: PrayTarget?
    @Published var currentFocusTime: TimeInterval = 0
    @Published var unreadRewards: [Reward] = []
    @Published var allRewards: [Reward] = []  // 所有历史奖励
    @Published var isShowingRewardDetail: Bool = false
    @Published var isShowingRewardSheet: Bool = false
    @Published var currentRewardToShow: Reward?
    @Published var currentRewardIndex: Int = 0
    @Published var todayIncenseCount: Int = 0
    @Published var initialUnreadRewardsCount: Int = 0
    
    // 祈福对象相关状态
    @Published var draggedPrayTarget: PrayTarget?
    @Published var shrineOccupiedTarget: PrayTarget?
    @Published var prayTargetPage: Int = 0
    
    // 背景图片相关状态
    @Published var currentBackgroundImage: String = "homepage_background"
    private let candidateBackgrounds = ["background_2", "background_3", "background_4"]
    
    // 新用户引导相关状态
    @Published var isFirstTimeUser: Bool = true
    @Published var onboardingStep: OnboardingStep = .welcome
    
    init() {
        // 确保初始化时背景图片已经设置
        currentBackgroundImage = "homepage_background"
        
        #if DEBUG
        // Debug模式下每次启动都重置为新手引导
        UserDefaults.standard.removeObject(forKey: "HasCompletedOnboarding")
        isFirstTimeUser = true
        onboardingStep = .welcome
        
        // Debug模式下添加测试奖励数据
        setupTestRewards()
        #else
        // 生产模式下检查是否为首次使用
        isFirstTimeUser = !UserDefaults.standard.bool(forKey: "HasCompletedOnboarding")
        if isFirstTimeUser {
            onboardingStep = .welcome
        }
        #endif
    }
    
    enum ViewType {
        case main
        case rewardDetail
        case rewardHistory
    }
    
    enum OnboardingStep {
        case welcome        // 首次进入："码祖庙 - 你的 vibecoding 守护神，两步即可祈福"
        case targetSelected // 选择祈福对象后："点击任意蜡烛，开始或结束祈福"
        case completed      // 开始专注后：显示正常信息栏
    }
    
    enum FocusState {
        case idle
        case focusing
        case paused
        
        var displayText: String {
            switch self {
            case .idle: return "准备祈福"
            case .focusing: return "祈福中"
            case .paused: return "已暂停"
            }
        }
    }
    
    // MARK: - 背景切换方法
    func switchToRandomBackground() {
        let availableBackgrounds = candidateBackgrounds.filter { $0 != currentBackgroundImage }
        if let randomBackground = availableBackgrounds.randomElement() {
            currentBackgroundImage = randomBackground
        } else if let anyBackground = candidateBackgrounds.randomElement() {
            currentBackgroundImage = anyBackground
        }
    }
    
    func resetToHomepageBackground() {
        currentBackgroundImage = "homepage_background"
    }
    
    func updateBackgroundForTarget(_ target: PrayTarget?) {
        if target != nil {
            // 有选择对象时，切换到随机背景
            switchToRandomBackground()
        } else {
            // 无选择对象时，重置为首页背景
            resetToHomepageBackground()
        }
    }
    
    #if DEBUG
    private func setupTestRewards() {
        // 添加一些测试用的未读奖励
        unreadRewards = [
            Reward(type: .physicalReward, title: "精美编程贴纸套装", content: "恭喜获得限量版编程语言贴纸套装！包含Swift、Python、JavaScript、TypeScript、Rust、Go等12种热门语言的精美贴纸，每个都有独特的设计风格。让你的MacBook、显示器或桌面更加个性化！", imageName: nil),
            Reward(type: .programmingTip, title: "Cursor AI 编程技巧", content: "使用 Cursor 时，尝试编写更详细的注释，AI 会根据注释生成更准确的代码建议。保持注释简洁明了，描述代码的意图而不是实现细节。好的注释是与AI协作的关键。", imageName: nil),
            Reward(type: .physicalReward, title: "程序员专属键帽", content: "获得一个专为程序员设计的定制ESC键帽！采用双色注塑工艺，印有经典的 'sudo' 字样。兼容Cherry MX轴体，让你的机械键盘瞬间提升逼格！", imageName: nil)
        ]
        
        // 添加一些历史奖励数据
        allRewards = [
            Reward(type: .programmingTip, title: "Git 最佳实践", content: "每次提交都应该是一个完整的逻辑单元，避免把多个不相关的修改放在同一个提交中。写好的提交信息应该清楚地描述'为什么'而不仅仅是'做了什么'。", imageName: nil),
            Reward(type: .physicalReward, title: "代码咖啡杯", content: "专属程序员马克杯来了！杯身印有经典代码片段和编程梗图，容量350ml，陶瓷材质，微波炉安全。", imageName: nil),
            Reward(type: .programmingTip, title: "SwiftUI 性能优化", content: "使用 @StateObject 而不是 @ObservableObject 来避免不必要的视图重建。当视图的父组件重新创建时，@StateObject 会保持对象的生命周期。", imageName: nil),
            Reward(type: .physicalReward, title: "GitHub 纪念T恤", content: "限量版 GitHub 黑色纯棉T恤！正面是简洁的 Octocat 图案，背面印有你的 GitHub 用户名。100%纯棉材质，舒适透气。", imageName: nil)
        ]
    }
    #endif
    
    // MARK: - 新用户引导方法
    func advanceOnboardingStep() {
        guard isFirstTimeUser else { return }
        
        switch onboardingStep {
        case .welcome:
            onboardingStep = .targetSelected
        case .targetSelected:
            completeOnboarding()
        case .completed:
            break
        }
    }
    
    func completeOnboarding() {
        onboardingStep = .completed
        isFirstTimeUser = false
        UserDefaults.standard.set(true, forKey: "HasCompletedOnboarding")
    }
}

struct PrayTarget: Identifiable, Equatable {
    let id: String
    let name: String
    let icon: String
    let category: Category
    
    enum Category: Equatable {
        case app
        case person
        case custom
    }
    
    static let presetTargets: [PrayTarget] = [
        PrayTarget(id: "lovable", name: "Lovable", icon: "Lovable_icon", category: .app),
        PrayTarget(id: "cursor", name: "Cursor", icon: "Cursor_icon", category: .app),
        PrayTarget(id: "trae", name: "Trae", icon: "Trae_icon", category: .app),
        PrayTarget(id: "kiro", name: "Kiro", icon: "kiro_icon", category: .app),
        PrayTarget(id: "github_copilot", name: "GitHub Copilot", icon: "GithubCopilot_icon", category: .app),
        PrayTarget(id: "perplexity", name: "Perplexity", icon: "Perplexity_icon", category: .app),
        PrayTarget(id: "gemini", name: "Gemini", icon: "Gemini_icon", category: .app),
        PrayTarget(id: "gpt5", name: "Codex", icon: "GPT5_icon", category: .app),
        PrayTarget(id: "claude_code", name: "Claude Code", icon: "ClaudeCode_icon", category: .app)
    ]
    
    // 分页支持：每页8个（2行4列）
    static func getPage(_ pageIndex: Int) -> [PrayTarget] {
        let startIndex = pageIndex * 8
        let endIndex = min(startIndex + 8, presetTargets.count)
        guard startIndex < presetTargets.count else { return [] }
        return Array(presetTargets[startIndex..<endIndex])
    }
    
    static var pageCount: Int {
        return (presetTargets.count + 5) / 6
    }
}



struct Reward: Identifiable, Equatable {
    let id = UUID()
    let type: RewardType
    let title: String
    let content: String
    let imageName: String?
    let timestamp = Date()
    var isRead: Bool = false
    
    static func == (lhs: Reward, rhs: Reward) -> Bool {
        lhs.id == rhs.id
    }
    
    enum RewardType {
        case physicalReward  // 实体奖励（图片+文字）
        case programmingTip  // 编程技巧（纯文字）
    }
}