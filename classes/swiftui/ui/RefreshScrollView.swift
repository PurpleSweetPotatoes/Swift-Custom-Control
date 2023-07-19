//
//  RefreshScrollView.swift
//  MyTestDemo
//
//  Created by baiqiang on 2023/7/19.
//

import SwiftUI

public struct RefreshScrollView<Content: View>: View {
    @StateObject private var viewModel = RefreshScrollViewModel()

    private let showsIndicators: Bool
    private let content: () -> Content
    private let offsetYDidChange: ((CGFloat) -> Void)?
    private let onRefresh: (() async -> Void)?

    public init(showsIndicators: Bool = false, content: @escaping () -> Content, offsetYDidChange: ((CGFloat) -> Void)? = nil, onRefresh: (() async -> Void)? = nil) {
        self.showsIndicators = showsIndicators
        self.content = content
        self.offsetYDidChange = offsetYDidChange
        self.onRefresh = onRefresh
    }

    public var body: some View {
        ScrollView(showsIndicators: showsIndicators) {
            GeometryReader { proxy in
                Rectangle().fill(Color.clear)
                    .frame(width: 0, height: 0)
                    .preference(key: RefreshScrollViewPreferenceKey.self, value: proxy.frame(in: .global).origin.y)
            }
            VStack(spacing: 0) {
                if onRefresh != nil {
                    ProgressView()
                        .frame(height: viewModel.isRefreshing ? 60 : max(60 * viewModel.process, 0))
                        .foregroundColor(Color.red)
                        .clipped()
                        .offset(y: -(viewModel.offsetY ?? 0) + viewModel.initialOffsetY)
                }
                content()
            }
        }
        .onPreferenceChange(RefreshScrollViewPreferenceKey.self) { value in
            if let _ = viewModel.offsetY {
                offsetYDidChange?(value - viewModel.initialOffsetY)
            }
            viewModel.didUpdateOffsetY(value)
        }
        .onChange(of: viewModel.isRefreshing) { isRefresh in
            guard isRefresh else { return }
            Task {
                await onRefresh?()
                viewModel.isRefreshing = false
            }
        }
    }
}

private struct RefreshScrollViewPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}

private final class RefreshScrollViewModel: ObservableObject {
    var offsetY: CGFloat?
    var initialOffsetY: CGFloat = 0.0
    private let distanceToTriggerRefresh: CGFloat = 80
    @Published var isRefreshing: Bool = false
    @Published var process: CGFloat = 0.0

    @MainActor
    func didUpdateOffsetY(_ value: CGFloat) {
        if let _ = offsetY {
            let process = min(value - initialOffsetY, distanceToTriggerRefresh) / distanceToTriggerRefresh
            self.process = min(max(0, process), 1)
            self.offsetY = value
            let difference = value - initialOffsetY
            if !isRefreshing,
               difference > distanceToTriggerRefresh {
                isRefreshing = true
            }
        } else {
            self.offsetY = value
            self.initialOffsetY = value
        }
    }
}
