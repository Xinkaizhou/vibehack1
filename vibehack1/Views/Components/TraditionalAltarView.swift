//
//  TraditionalAltarView.swift
//  vibehack1
//
//  Created by Daniel on 2025/9/12.
//

import SwiftUI

// MARK: - 传统祭坛主界面
struct TraditionalAltarView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var timerManager: FocusTimerManager
    
    var body: some View {
        ZStack {
            // 背景图片
            Image("neon_altar_background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
            
            VStack(spacing: 0) {
                // 上部分：祈福对象区域 - 往下移动
                VStack {
                    Spacer()
                        .frame(height: 30)
                    CentralAltarArea()
                    Spacer()
                }
                .frame(height: 180)
                
                // 中部分：空间分隔 - 减少间距
                Spacer()
                    .frame(height: 60)
                
                // 下部分：蜡烛区域 - 往上移动
                VStack {
                    HStack(spacing: 120) {
                        TraditionalCandleView(position: .left)
                        TraditionalCandleView(position: .right)
                    }
                    Spacer()
                        .frame(height: 40)
                }
                .frame(height: 120)
            }
            .overlay(
                // 整体烟雾氛围效果
                AltarAmbienceSmoke()
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - 星空背景
struct StarryNightBackground: View {
    @State private var twinklePhase: Double = 0
    
    var body: some View {
        ZStack {
            // 深蓝夜空渐变
            LinearGradient(
                colors: [
                    Color(.sRGB, red: 0.05, green: 0.1, blue: 0.2),
                    Color(.sRGB, red: 0.1, green: 0.15, blue: 0.3),
                    Color(.sRGB, red: 0.2, green: 0.25, blue: 0.4)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // 星星
            ForEach(0..<50, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: starSize(for: index), height: starSize(for: index))
                    .position(starPosition(for: index))
                    .opacity(starOpacity(for: index))
                    .animation(
                        .easeInOut(duration: Double.random(in: 2...4))
                        .repeatForever(autoreverses: true)
                        .delay(Double.random(in: 0...2)),
                        value: twinklePhase
                    )
            }
        }
        .onAppear {
            twinklePhase = 1
        }
    }
    
    private func starSize(for index: Int) -> CGFloat {
        let sizes: [CGFloat] = [1, 1.5, 2, 2.5, 3]
        return sizes[index % sizes.count]
    }
    
    private func starPosition(for index: Int) -> CGPoint {
        // 使用固定随机种子确保星星位置稳定
        let x = CGFloat((index * 17 + 23) % 400) + 50
        let y = CGFloat((index * 31 + 47) % 300) + 50
        return CGPoint(x: x, y: y)
    }
    
    private func starOpacity(for index: Int) -> Double {
        0.3 + 0.7 * sin(twinklePhase * .pi + Double(index) * 0.1)
    }
}

// MARK: - 祭坛平台
struct AltarPlatformView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            // 祭坛台面
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.clear)
                .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)
            
            // 祭坛内容
            HStack(spacing: 60) {
                // 左侧蜡烛
                TraditionalCandleView(position: .left)
                
                // 中央祈福对象区域
                CentralAltarArea()
                
                // 右侧蜡烛
                TraditionalCandleView(position: .right)
            }
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: 400)
    }
}

// MARK: - 传统蜡烛
struct TraditionalCandleView: View {
    let position: CandlePosition
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var timerManager: FocusTimerManager
    
    enum CandlePosition {
        case left, right
    }
    
    private var isLit: Bool {
        appState.focusState == .focusing
    }
    
    private var canLight: Bool {
        appState.shrineOccupiedTarget != nil && appState.focusState == .idle
    }
    
    var body: some View {
        VStack(spacing: 4) {
            // 隐藏烟雾效果
            // if isLit {
            //     LottieCandleSmokeView()
            //         .frame(width: 30, height: 60)
            //         .offset(y: -20)  // 烟雾在火焰上方
            // } else {
            //     Spacer()
            //         .frame(height: 60)
            // }
            
            // 火焰（仅在点燃时显示）
            if isLit {
                LottieFireView()
                    .frame(width: 15, height: 20)  // 很小的火焰
                    .offset(y: 5)  // 贴近蜡烛芯
            } else {
                Spacer()
                    .frame(height: 16)
            }
            
            
            // 蜡烛主体
            Button(action: handleCandleClick) {
                VStack(spacing: 0) {
                    // 蜡烛芯 - 改为白色以提高可见度
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 2, height: isLit ? 6 : 8)
                    
                    // 蜡烛本体 - 使用更明亮的米色
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(.sRGB, red: 0.98, green: 0.95, blue: 0.88),
                                    Color(.sRGB, red: 0.95, green: 0.92, blue: 0.85),
                                    Color(.sRGB, red: 0.92, green: 0.89, blue: 0.82)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 16, height: 60)
                        // 移除蜡泪效果
                        // .overlay(
                        //     // 蜡泪效果
                        //     VStack {
                        //         if isLit {
                        //             ForEach(0..<3, id: \.self) { index in
                        //                 Circle()
                        //                     .fill(Color(.sRGB, red: 0.95, green: 0.92, blue: 0.85))
                        //                     .frame(width: 3, height: 3)
                        //                     .offset(x: CGFloat.random(in: -6...6), y: CGFloat(index * 8) + 10)
                        //                     .opacity(0.8)
                        //             }
                        //         }
                        //     }
                        // )
                }
            }
            .buttonStyle(.plain)
            .disabled(!canLight && appState.focusState != .focusing)
            
        }
    }
    
    private func handleCandleClick() {
        if appState.focusState == .focusing {
            // 熄灭蜡烛，结束专注
            timerManager.endFocus()
        } else if canLight {
            // 点燃蜡烛，开始专注
            timerManager.startFocus()
            // 累计上香次数
            appState.todayIncenseCount += 1
        }
    }
}


// MARK: - 蜡烛火焰
struct CandleFlameView: View {
    @State private var flameOffset: CGFloat = 0
    @State private var flameScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // 火焰外层（橙色）
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.orange.opacity(0.9),
                            Color.red.opacity(0.7),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 2,
                        endRadius: 8
                    )
                )
                .frame(width: 12, height: 16)
                .scaleEffect(flameScale)
                .offset(x: flameOffset)
            
            // 火焰内层（黄色）
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.yellow.opacity(0.9),
                            Color.orange.opacity(0.6),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 1,
                        endRadius: 5
                    )
                )
                .frame(width: 8, height: 12)
                .scaleEffect(flameScale * 0.8)
                .offset(x: flameOffset * 0.5)
        }
        .onAppear {
            // 火焰摆动动画
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                flameOffset = 1
            }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                flameScale = 1.1
            }
        }
    }
}

// MARK: - 中央祈福区域
struct CentralAltarArea: View {
    @EnvironmentObject var appState: AppState
    @State private var showingSelection = false
    
    var body: some View {
        VStack(spacing: 8) {
            // 祈福对象展示区域
            Button(action: {
                showingSelection = true
            }) {
                ZStack {
                    // 神龛背景
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(.sRGB, red: 0.2, green: 0.15, blue: 0.1),
                                    Color(.sRGB, red: 0.15, green: 0.1, blue: 0.08),
                                    Color.black.opacity(0.8)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 100, height: 80)
                    
                    // 祈福对象或提示
                    if let target = appState.shrineOccupiedTarget {
                        VStack(spacing: 4) {
                            Image(systemName: target.icon)
                                .font(.system(size: 24))
                                .foregroundColor(.yellow)
                                .shadow(color: .yellow.opacity(0.5), radius: 4)
                            
                            Text(target.name)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                        }
                    } else {
                        VStack(spacing: 4) {
                            Image(systemName: "hand.tap")
                                .font(.title3)
                                .foregroundColor(.gray)
                            
                            Text("选择祈福对象")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .buttonStyle(.plain)
            
            // 祝福语
            if let target = appState.shrineOccupiedTarget {
                Text(target.blessing)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 120)
                    .lineLimit(2)
            }
        }
        .sheet(isPresented: $showingSelection) {
            PrayTargetSelectionSheet()
        }
    }
}

// MARK: - 祭坛底座
struct AltarBaseView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.clear)
            .frame(maxWidth: 420)
            .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 2)
    }
}

// MARK: - 蜡烛烟雾效果
struct CandleSmokeView: View {
    @State private var smokeParticles: [SmokeParticle] = []
    @State private var animationTimer: Timer?
    
    struct SmokeParticle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var opacity: Double
        var scale: CGFloat
        var rotation: Double
        
        init() {
            self.x = CGFloat.random(in: -5...5)
            self.y = 0
            self.opacity = 0.6
            self.scale = CGFloat.random(in: 0.3...0.8)
            self.rotation = Double.random(in: 0...360)
        }
    }
    
    var body: some View {
        ZStack {
            // 烟雾粒子
            ForEach(smokeParticles) { particle in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.gray.opacity(particle.opacity * 0.4),
                                Color.gray.opacity(particle.opacity * 0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 1,
                            endRadius: 8
                        )
                    )
                    .frame(width: 12 * particle.scale, height: 12 * particle.scale)
                    .position(x: 15 + particle.x, y: 40 - particle.y)
                    .rotationEffect(.degrees(particle.rotation))
                    .opacity(particle.opacity)
            }
        }
        .onAppear {
            startSmokeAnimation()
        }
        .onDisappear {
            stopSmokeAnimation()
        }
    }
    
    private func startSmokeAnimation() {
        // 初始生成一些烟雾粒子
        generateInitialSmoke()
        
        // 启动动画计时器
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            updateSmokeParticles()
        }
    }
    
    private func stopSmokeAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func generateInitialSmoke() {
        smokeParticles = Array(0..<8).map { index in
            var particle = SmokeParticle()
            particle.y = CGFloat(index) * 5 + CGFloat.random(in: 0...3)
            particle.opacity = 0.6 - (Double(index) * 0.07)
            return particle
        }
    }
    
    private func updateSmokeParticles() {
        withAnimation(.linear(duration: 0.05)) {
            // 更新现有粒子
            for i in smokeParticles.indices {
                smokeParticles[i].y += CGFloat.random(in: 0.8...1.5)
                smokeParticles[i].x += CGFloat.random(in: -0.3...0.3)
                smokeParticles[i].opacity *= 0.98
                smokeParticles[i].scale *= 1.02
                smokeParticles[i].rotation += Double.random(in: -2...2)
            }
            
            // 移除消失的粒子
            smokeParticles.removeAll { $0.opacity < 0.1 || $0.y > 50 }
            
            // 随机生成新粒子
            if Double.random(in: 0...1) < 0.7 {
                smokeParticles.append(SmokeParticle())
            }
            
            // 限制粒子数量
            if smokeParticles.count > 15 {
                smokeParticles.removeFirst(smokeParticles.count - 15)
            }
        }
    }
}

// MARK: - 祭坛整体烟雾氛围
struct AltarAmbienceSmoke: View {
    @EnvironmentObject var appState: AppState
    @State private var ambienceParticles: [AmbienceParticle] = []
    @State private var animationTimer: Timer?
    
    struct AmbienceParticle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var opacity: Double
        var scale: CGFloat
        var driftSpeed: CGFloat
        
        init(containerWidth: CGFloat) {
            self.x = CGFloat.random(in: 50...(containerWidth - 50))
            self.y = 0
            self.opacity = Double.random(in: 0.1...0.3)
            self.scale = CGFloat.random(in: 0.5...1.2)
            self.driftSpeed = CGFloat.random(in: 0.3...0.8)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 环境烟雾粒子
                ForEach(ambienceParticles) { particle in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(particle.opacity * 0.3),
                                    Color.gray.opacity(particle.opacity * 0.2),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 2,
                                endRadius: 15
                            )
                        )
                        .frame(width: 20 * particle.scale, height: 20 * particle.scale)
                        .position(x: particle.x, y: geometry.size.height - particle.y)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                if appState.focusState == .focusing {
                    startAmbienceAnimation(containerWidth: geometry.size.width)
                }
            }
            .onDisappear {
                stopAmbienceAnimation()
            }
            .onChange(of: appState.focusState) { _, focusState in
                if focusState == .focusing {
                    startAmbienceAnimation(containerWidth: geometry.size.width)
                } else {
                    stopAmbienceAnimation()
                }
            }
        }
    }
    
    private func startAmbienceAnimation(containerWidth: CGFloat) {
        // 生成初始环境烟雾
        ambienceParticles = Array(0..<5).map { _ in
            var particle = AmbienceParticle(containerWidth: containerWidth)
            particle.y = CGFloat.random(in: 0...100)
            return particle
        }
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            updateAmbienceParticles(containerWidth: containerWidth)
        }
    }
    
    private func stopAmbienceAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
        withAnimation(.easeOut(duration: 2.0)) {
            ambienceParticles.removeAll()
        }
    }
    
    private func updateAmbienceParticles(containerWidth: CGFloat) {
        withAnimation(.linear(duration: 0.1)) {
            // 更新现有粒子
            for i in ambienceParticles.indices {
                ambienceParticles[i].y += ambienceParticles[i].driftSpeed
                ambienceParticles[i].x += CGFloat.random(in: -0.2...0.2)
                ambienceParticles[i].opacity *= 0.995
            }
            
            // 移除消失的粒子
            ambienceParticles.removeAll { $0.opacity < 0.05 || $0.y > 200 }
            
            // 随机生成新的环境烟雾
            if Double.random(in: 0...1) < 0.3 {
                ambienceParticles.append(AmbienceParticle(containerWidth: containerWidth))
            }
            
            // 限制粒子数量
            if ambienceParticles.count > 8 {
                ambienceParticles.removeFirst(ambienceParticles.count - 8)
            }
        }
    }
}

#Preview {
    let appState = AppState()
    let timerManager = FocusTimerManager(appState: appState)
    
    TraditionalAltarView()
        .environmentObject(appState)
        .environmentObject(timerManager)
        .frame(width: 600, height: 400)
}