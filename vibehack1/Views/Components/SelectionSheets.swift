//
//  SelectionSheets.swift
//  vibehack1
//
//  Created by Daniel on 2025/9/12.
//

import SwiftUI

// MARK: - 祈福对象选择弹窗
struct PrayTargetSelectionSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTarget: PrayTarget?
    
    var body: some View {
        VStack(spacing: 16) {
            Text("选择码神")
                .font(.title2)
                .fontWeight(.semibold)
            
            // 6宫格横滑选择（3x2布局）
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(0..<PrayTarget.pageCount, id: \.self) { pageIndex in
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                            ForEach(targetsForPage(pageIndex), id: \.id) { target in
                                PrayTargetSheetItem(
                                    target: target,
                                    isSelected: selectedTarget?.id == target.id,
                                    onTap: {
                                        selectedTarget = target
                                    }
                                )
                            }
                            
                            // 填充空白格子到6个
                            ForEach(targetsForPage(pageIndex).count..<6, id: \.self) { _ in
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width: 80, height: 80)
                            }
                        }
                        .frame(width: 280)
                    }
                }
                .padding(.horizontal, 20)
            }
            .frame(height: 180)
            
            // 确认和取消按钮
            HStack(spacing: 16) {
                Button("取消") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                
                Button("确认选择") {
                    if let target = selectedTarget {
                        appState.shrineOccupiedTarget = target
                    }
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(selectedTarget == nil)
            }
        }
        .padding(20)
        .frame(width: 400, height: 280)
        .background(Color(.windowBackgroundColor))
        .cornerRadius(12)
        .onAppear {
            selectedTarget = appState.shrineOccupiedTarget
        }
    }
    
    private func targetsForPage(_ pageIndex: Int) -> [PrayTarget] {
        let startIndex = pageIndex * 6
        let endIndex = min(startIndex + 6, PrayTarget.presetTargets.count)
        guard startIndex < PrayTarget.presetTargets.count else { return [] }
        return Array(PrayTarget.presetTargets[startIndex..<endIndex])
    }
}

struct PrayTargetSheetItem: View {
    let target: PrayTarget
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: target.icon)
                    .font(.system(size: 32))
                    .foregroundColor(isSelected ? .white : .accentColor)
                
                Text(target.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .lineLimit(2)
            }
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor : Color.white)
                    .shadow(color: .black.opacity(0.15), radius: isSelected ? 6 : 3, x: 0, y: 2)
            )
            .scaleEffect(isSelected ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}



#Preview {
    let appState = AppState()
    PrayTargetSelectionSheet()
        .environmentObject(appState)
}