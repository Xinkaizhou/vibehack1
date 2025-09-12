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
    
    enum ViewType {
        case main
        case rewardDetail
    }
    
    enum FocusState {
        case idle
        case focusing
        case paused
        
        var displayText: String {
            switch self {
            case .idle: return "准备专注"
            case .focusing: return "专注中"
            case .paused: return "已暂停"
            }
        }
    }
}

struct PrayTarget: Identifiable {
    let id: String
    let name: String
    let icon: String
    let blessing: String
    let category: Category
    
    enum Category {
        case app
        case person
        case custom
    }
    
    static let presetTargets: [PrayTarget] = [
        PrayTarget(id: "cursor", name: "Cursor", icon: "terminal.fill", blessing: "愿代码无Bug，AI助力高效编程", category: .app),
        PrayTarget(id: "claude", name: "Claude Code", icon: "brain.filled.head.profile", blessing: "愿AI陪伴，思路清晰如流水", category: .app),
        PrayTarget(id: "vscode", name: "VS Code", icon: "chevron.left.forwardslash.chevron.right", blessing: "愿编辑器顺手，开发如有神助", category: .app),
        PrayTarget(id: "github", name: "GitHub", icon: "externaldrive.connected.to.line.below.fill", blessing: "愿代码提交顺利，协作无阻碍", category: .app),
        PrayTarget(id: "xcode", name: "Xcode", icon: "hammer.fill", blessing: "愿构建成功，应用发布无忧", category: .app),
        PrayTarget(id: "swift", name: "Swift", icon: "swift", blessing: "愿Swift代码优雅，性能卓越", category: .app),
        PrayTarget(id: "python", name: "Python", icon: "diamond.fill", blessing: "愿Python脚本高效，数据清晰", category: .app),
        PrayTarget(id: "docker", name: "Docker", icon: "shippingbox.fill", blessing: "愿容器运行稳定，部署无忧", category: .app)
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