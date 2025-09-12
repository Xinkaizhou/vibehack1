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
    @Published var isShowingRewardDetail: Bool = false
    @Published var todayIncenseCount: Int = 0
    
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
        if let target = target {
            // 有选择对象时，切换到随机背景
            switchToRandomBackground()
        } else {
            // 无选择对象时，重置为首页背景
            resetToHomepageBackground()
        }
    }
    
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
    let rarity: Rarity
    let timestamp = Date()
    var isRead: Bool = false
    
    static func == (lhs: Reward, rhs: Reward) -> Bool {
        lhs.id == rhs.id
    }
    
    enum RewardType {
        case programmingTip
        case motivation
        case achievement
        case blessing
    }
    
    enum Rarity {
        case common
        case rare
        case epic
        
        var displayName: String {
            switch self {
            case .common: return "普通"
            case .rare: return "稀有"
            case .epic: return "史诗"
            }
        }
        
        var color: Color {
            switch self {
            case .common: return .gray
            case .rare: return .blue
            case .epic: return .purple
            }
        }
    }
}