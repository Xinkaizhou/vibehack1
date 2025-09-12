//
//  RealLottieView.swift
//  vibehack1
//
//  Created by Daniel on 2025/9/12.
//

import SwiftUI
import Lottie
import AppKit

struct RealLottieView: NSViewRepresentable {
    let animationName: String
    let loopMode: LottieLoopMode
    let contentMode: LottieContentMode
    let animationSpeed: CGFloat
    
    init(animationName: String, 
         loopMode: LottieLoopMode = .loop,
         contentMode: LottieContentMode = .scaleAspectFit,
         animationSpeed: CGFloat = 1.0) {
        self.animationName = animationName
        self.loopMode = loopMode
        self.contentMode = contentMode
        self.animationSpeed = animationSpeed
    }
    
    func makeNSView(context: Context) -> NSView {
        let containerView = NSView()
        let animationView = LottieAnimationView()
        
        // 加载动画文件
        if let animation = LottieAnimation.named(animationName) {
            animationView.animation = animation
            animationView.contentMode = contentMode
            animationView.loopMode = loopMode
            animationView.animationSpeed = animationSpeed
            animationView.play()
        } else {
            print("⚠️ Could not load Lottie animation: \(animationName)")
        }
        
        // 设置自动布局
        animationView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: containerView.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        // 如果需要更新动画
        if let animationView = nsView.subviews.first as? LottieAnimationView {
            if animationView.animation == nil {
                if let animation = LottieAnimation.named(animationName) {
                    animationView.animation = animation
                    animationView.play()
                }
            }
        }
    }
}

// 火焰动画专用视图
struct LottieFireView: View {
    @State private var isAnimating = false
    
    var body: some View {
        RealLottieView(
            animationName: "Fire",
            loopMode: .loop,
            contentMode: .scaleAspectFit,
            animationSpeed: 1.2
        )
        .scaleEffect(isAnimating ? 0.04 : 0.03)  // 3-4% 大小的火焰
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

// 蜡烛小烟雾动画（替换 CandleSmokeView）
struct LottieCandleSmokeView: View {
    var body: some View {
        RealLottieView(
            animationName: "GradientSmoke",
            loopMode: .loop,
            contentMode: .scaleAspectFit,
            animationSpeed: 0.3  // 很慢的速度
        )
        .scaleEffect(0.15)  // 非常小的烟雾
        .opacity(0.3)  // 轻微可见
        .blur(radius: 2)  // 轻微模糊
    }
}

// 背景烟雾动画专用视图（用于整体氛围）
struct LottieSmokeView: View {
    var body: some View {
        RealLottieView(
            animationName: "GradientSmoke",
            loopMode: .loop,
            contentMode: .scaleAspectFit,
            animationSpeed: 0.5
        )
        .scaleEffect(0.8)
        .opacity(0.15)  // 非常透明
        .blur(radius: 10)  // 高度模糊作为背景
    }
}

#Preview {
    VStack(spacing: 50) {
        // 火焰预览
        LottieFireView()
            .frame(width: 50, height: 70)
            .background(Color.black.opacity(0.1))
        
        // 烟雾预览
        LottieSmokeView()
            .frame(width: 300, height: 300)
            .background(Color.black.opacity(0.1))
    }
    .padding()
}