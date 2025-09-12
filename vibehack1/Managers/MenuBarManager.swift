//
//  MenuBarManager.swift
//  vibehack1
//
//  Created by Daniel on 2025/9/12.
//

import AppKit
import SwiftUI

class MenuBarManager: NSObject, ObservableObject {
    private var statusItem: NSStatusItem?
    private let appState: AppState
    private let timerManager: FocusTimerManager
    
    init(appState: AppState, timerManager: FocusTimerManager) {
        self.appState = appState
        self.timerManager = timerManager
        super.init()
        setupStatusItem()
        startObserving()
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            updateStatusBarDisplay()
            button.target = self
            button.action = #selector(statusItemClicked)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        updateContextMenu()
    }
    
    private func startObserving() {
        // 监听应用状态变化并更新菜单栏显示
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateStatusBarDisplay()
                self?.updateContextMenu()
            }
        }
    }
    
    @objc private func statusItemClicked() {
        guard let event = NSApp.currentEvent else { return }
        
        switch event.type {
        case .leftMouseUp:
            toggleMainWindow()
        case .rightMouseUp:
            // 右键菜单会自动显示
            break
        default:
            break
        }
    }
    
    private func toggleMainWindow() {
        if let window = NSApp.windows.first(where: { $0.contentViewController != nil }) {
            if window.isVisible && window.isKeyWindow {
                window.orderOut(nil)
            } else {
                window.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
    
    private func updateStatusBarDisplay() {
        guard let button = statusItem?.button else { return }
        
        let (title, shouldBlink) = getStatusTitle()
        
        button.title = title
        
        // 处理闪烁效果
        if shouldBlink {
            startBlinking()
        } else {
            stopBlinking()
        }
    }
    
    private func getStatusTitle() -> (String, Bool) {
        switch appState.focusState {
        case .idle:
            return ("🕯️", false)
        case .focusing:
            let timeText = timerManager.menuBarFormattedTime
            return ("🔥 \(timeText)", false)
        case .paused:
            let timeText = timerManager.menuBarFormattedTime
            return ("⏸️ \(timeText)", true)
        }
    }
    
    private var blinkTimer: Timer?
    
    private func startBlinking() {
        guard blinkTimer == nil else { return }
        
        blinkTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let button = self.statusItem?.button else { return }
            
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.5
                button.animator().alphaValue = button.alphaValue == 1.0 ? 0.3 : 1.0
            }
        }
    }
    
    private func stopBlinking() {
        blinkTimer?.invalidate()
        blinkTimer = nil
        statusItem?.button?.alphaValue = 1.0
    }
    
    private func updateContextMenu() {
        let menu = NSMenu()
        
        switch appState.focusState {
        case .idle:
            menu.addItem(NSMenuItem(title: "显示主窗口", action: #selector(showMainWindow), keyEquivalent: ""))
            menu.addItem(NSMenuItem.separator())
            
        case .focusing:
            let focusInfo = NSMenuItem(title: "祈福中 - \(timerManager.menuBarFormattedTime)", action: nil, keyEquivalent: "")
            focusInfo.isEnabled = false
            menu.addItem(focusInfo)
            
            if let target = appState.selectedPrayTarget {
                let targetInfo = NSMenuItem(title: "祈福对象: \(target.name)", action: nil, keyEquivalent: "")
                targetInfo.isEnabled = false
                menu.addItem(targetInfo)
            }
            
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "暂停祈福", action: #selector(pauseFocus), keyEquivalent: ""))
            menu.addItem(NSMenuItem(title: "结束祈福", action: #selector(endFocus), keyEquivalent: ""))
            menu.addItem(NSMenuItem.separator())
            
        case .paused:
            let pauseInfo = NSMenuItem(title: "暂停中 - \(timerManager.menuBarFormattedTime)", action: nil, keyEquivalent: "")
            pauseInfo.isEnabled = false
            menu.addItem(pauseInfo)
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "继续祈福", action: #selector(resumeFocus), keyEquivalent: ""))
            menu.addItem(NSMenuItem(title: "结束祈福", action: #selector(endFocus), keyEquivalent: ""))
            menu.addItem(NSMenuItem.separator())
        }
        
        // 福报奖励信息
        if !appState.unreadRewards.isEmpty {
            let rewardItem = NSMenuItem(title: "🎁 \(appState.unreadRewards.count) 个新福报奖励", action: #selector(showRewards), keyEquivalent: "")
            menu.addItem(rewardItem)
            menu.addItem(NSMenuItem.separator())
        }
        
        // 通用菜单项
        menu.addItem(NSMenuItem(title: "显示主窗口", action: #selector(showMainWindow), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "退出", action: #selector(quitApp), keyEquivalent: "q"))
        
        // 设置target
        for item in menu.items {
            item.target = self
        }
        
        statusItem?.menu = menu
    }
    
    @objc private func showMainWindow() {
        if let window = NSApp.windows.first(where: { $0.contentViewController != nil }) {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    @objc private func showRewards() {
        showMainWindow()
        appState.currentView = .rewardDetail
    }
    
    @objc private func pauseFocus() {
        timerManager.pauseFocus()
    }
    
    @objc private func resumeFocus() {
        timerManager.resumeFocus()
    }
    
    @objc private func endFocus() {
        timerManager.endFocus()
    }
    
    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
    
    deinit {
        blinkTimer?.invalidate()
        NSStatusBar.system.removeStatusItem(statusItem!)
    }
}