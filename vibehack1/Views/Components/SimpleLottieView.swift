//
//  SimpleLottieView.swift
//  vibehack1
//
//  Created by Daniel on 2025/9/12.
//

import SwiftUI

// 简化的Lottie视图 - 不需要外部库
struct SimpleLottieView: View {
    let animationName: String
    let loopMode: Bool
    @State private var animationPhase: CGFloat = 0
    
    var body: some View {
        Group {
            if animationName == "Fire" {
                // 火焰动画的简化实现
                FireAnimationView(animationPhase: animationPhase)
            } else if animationName == "Gradient Smoke" {
                // 烟雾动画的简化实现
                SmokeAnimationView(animationPhase: animationPhase)
            } else {
                // 默认占位符
                EmptyView()
            }
        }
        .onAppear {
            if loopMode {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    animationPhase = 1
                }
            }
        }
    }
}

// 基于Fire.json的简化火焰动画
struct FireAnimationView: View {
    let animationPhase: CGFloat
    @State private var flameHeight: CGFloat = 1.0
    @State private var flameWidth: CGFloat = 1.0
    @State private var innerFlameOffset: CGFloat = 0
    
    private var outerFlameGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.553, blue: 0.102),
                Color(red: 0.984, green: 0.376, blue: 0.129),
                Color(red: 0.957, green: 0.259, blue: 0.212),
                Color.clear
            ],
            startPoint: .bottom,
            endPoint: .top
        )
    }
    
    private var innerFlameGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 1, green: 0.918, blue: 0.467),
                Color(red: 1, green: 0.949, blue: 0.62),
                Color(red: 1, green: 0.98, blue: 0.773),
                Color.clear
            ],
            startPoint: .bottom,
            endPoint: .top
        )
    }
    
    private var outerFlameWidth: CGFloat {
        14 * flameWidth
    }
    
    private var outerFlameHeight: CGFloat {
        20 * flameHeight
    }
    
    private var innerFlameWidth: CGFloat {
        8 * flameWidth
    }
    
    private var innerFlameHeight: CGFloat {
        14 * flameHeight
    }
    
    private var outerFlameScale: CGSize {
        CGSize(width: 1.0 + animationPhase * 0.1,
               height: 1.0 + animationPhase * 0.15)
    }
    
    private var innerFlameScale: CGSize {
        CGSize(width: 1.0 + animationPhase * 0.08,
               height: 1.0 + animationPhase * 0.12)
    }
    
    private var outerFlameOffset: CGSize {
        CGSize(width: sin(animationPhase * .pi * 4) * 1.5, height: -2)
    }
    
    private var innerFlameOffsetSize: CGSize {
        CGSize(width: sin(animationPhase * .pi * 4) * 0.8, height: 0)
    }
    
    var body: some View {
        ZStack {
            // 外层火焰
            Ellipse()
                .fill(outerFlameGradient)
                .frame(width: outerFlameWidth, height: outerFlameHeight)
                .scaleEffect(outerFlameScale)
                .offset(outerFlameOffset)
            
            // 内层火焰
            Ellipse()
                .fill(innerFlameGradient)
                .frame(width: innerFlameWidth, height: innerFlameHeight)
                .scaleEffect(innerFlameScale)
                .offset(innerFlameOffsetSize)
                .opacity(0.9)
            
            // 火花粒子
            ForEach(0..<3, id: \.self) { index in
                sparkParticle(index: index)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func sparkParticle(index: Int) -> some View {
        Circle()
            .fill(Color.orange.opacity(0.8))
            .frame(width: 2, height: 2)
            .offset(
                x: sin(animationPhase * .pi * 2 + CGFloat(index)) * 5,
                y: -10 - animationPhase * 20 + CGFloat(index * 5)
            )
            .opacity(1.0 - animationPhase)
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
            flameHeight = 1.15
            flameWidth = 0.95
        }
        
        withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
            innerFlameOffset = 1
        }
    }
}

// 基于Gradient Smoke.json的简化烟雾动画
struct SmokeAnimationView: View {
    let animationPhase: CGFloat
    @State private var smokeOpacity: Double = 0.5
    @State private var smokeOffset: CGFloat = 0
    @State private var smokeScale: CGFloat = 1.0
    
    private var smokeGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(white: 0.851, opacity: smokeOpacity),
                Color(white: 0.678, opacity: smokeOpacity * 0.7),
                Color(white: 0.631, opacity: smokeOpacity * 0.4)
            ],
            startPoint: .bottom,
            endPoint: .top
        )
    }
    
    var body: some View {
        ZStack {
            // 简化的烟雾效果
            ForEach(0..<5, id: \.self) { index in
                smokeLayer(index: index)
            }
        }
        .onAppear {
            startSmokeAnimation()
        }
    }
    
    private func smokeLayer(index: Int) -> some View {
        Circle()
            .fill(smokeGradient)
            .frame(width: 60, height: 60)
            .blur(radius: 10)
            .offset(
                x: sin(animationPhase * .pi + Double(index)) * 30,
                y: -smokeOffset - CGFloat(index * 30)
            )
            .opacity(smokeOpacity * (1.0 - Double(index) * 0.15))
            .scaleEffect(smokeScale + CGFloat(index) * 0.1)
    }
    
    private func startSmokeAnimation() {
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            smokeOffset = 100
        }
        
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            smokeScale = 1.3
            smokeOpacity = 0.3
        }
    }
}

#Preview {
    VStack(spacing: 50) {
        SimpleLottieView(animationName: "Fire", loopMode: true)
            .frame(width: 30, height: 40)
            .background(Color.black)
        
        SimpleLottieView(animationName: "Gradient Smoke", loopMode: true)
            .frame(width: 200, height: 200)
            .background(Color.black)
    }
}