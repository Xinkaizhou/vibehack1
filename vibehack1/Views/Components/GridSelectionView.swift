//
//  GridSelectionView.swift
//  vibehack1
//
//  Created by Daniel on 2025/9/12.
//

import SwiftUI

struct GridSelectionView<T: Identifiable>: View {
    let items: [T]
    let pageCount: Int
    let currentPage: Int
    let onPageChange: (Int) -> Void
    let itemContent: (T) -> AnyView
    
    var body: some View {
        VStack(spacing: 8) {
            // 4宫格内容区域
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(Array(currentPageItems.enumerated()), id: \.element.id) { index, item in
                    itemContent(item)
                        .frame(width: 60, height: 50)
                }
                
                // 填充空白格子到4个
                ForEach(currentPageItems.count..<4, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 60, height: 50)
                }
            }
            .frame(height: 120)
            .gesture(
                DragGesture()
                    .onEnded { value in
                        handleSwipeGesture(value)
                    }
            )
            
            // 分页指示器
            if pageCount > 1 {
                PageIndicatorView(currentPage: currentPage, totalPages: pageCount)
            }
        }
    }
    
    private var currentPageItems: [T] {
        let startIndex = currentPage * 4
        let endIndex = min(startIndex + 4, items.count)
        guard startIndex < items.count else { return [] }
        return Array(items[startIndex..<endIndex])
    }
    
    private func handleSwipeGesture(_ value: DragGesture.Value) {
        let threshold: CGFloat = 50
        
        if value.translation.height > threshold && currentPage > 0 {
            // 向下滑动 - 上一页
            withAnimation(.easeInOut(duration: 0.3)) {
                onPageChange(currentPage - 1)
            }
        } else if value.translation.height < -threshold && currentPage < pageCount - 1 {
            // 向上滑动 - 下一页
            withAnimation(.easeInOut(duration: 0.3)) {
                onPageChange(currentPage + 1)
            }
        }
    }
}

struct PageIndicatorView: View {
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.accentColor : Color.gray.opacity(0.3))
                    .frame(width: 6, height: 6)
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
    }
}

// MARK: - 祈福对象专用组件
struct PrayTargetGridView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "hands.sparkles.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
                Text("祈福对象")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            GridSelectionView(
                items: PrayTarget.presetTargets,
                pageCount: PrayTarget.pageCount,
                currentPage: appState.prayTargetPage,
                onPageChange: { newPage in
                    appState.prayTargetPage = newPage
                },
                itemContent: { target in
                    AnyView(PrayTargetGridItem(target: target))
                }
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.controlBackgroundColor))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
    }
}

struct PrayTargetGridItem: View {
    let target: PrayTarget
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: target.icon)
                .font(.title2)
                .foregroundColor(.accentColor)
            
            Text(target.name)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(1)
        }
        .frame(width: 65, height: 55)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
        )
        .scaleEffect(0.95)
        .onDrag {
            appState.draggedPrayTarget = target
            return NSItemProvider(object: target.id as NSString)
        }
    }
}


#Preview {
    let appState = AppState()
    
    VStack(spacing: 20) {
        PrayTargetGridView()
    }
    .environmentObject(appState)
    .padding()
    .frame(width: 300, height: 400)
}