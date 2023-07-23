//
//  RefreshScrollView.swift
//  MyTestDemo
//
//  Created by baiqiang on 2023/7/19.
//

import SwiftUI

private enum Constants {
    static let ProgressViewHeight: CGFloat = 60
    static let triggerRefreshHeight: CGFloat = 80
}

public struct RefreshScrollView<Content: View>: View {
    @StateObject private var viewModel = RefreshScrollViewModel()
    private let content: () -> Content
    private let offsetChanged: ((CGFloat) -> Void)?
    private let onRefresh: (() async -> Void)?

    public init(content: @escaping () -> Content, offsetChanged: ((CGFloat) -> Void)? = nil, onRefresh: (() async -> Void)? = nil) {
        self.content = content
        self.offsetChanged = offsetChanged
        self.onRefresh = onRefresh
    }

    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                GeometryReader { proxy in
                    Rectangle().fill(
                        Color.clear)
                        .frame(width: 0, height: 0)
                        .preference(key: RefreshScrollViewPreferenceKey.self, value: proxy.frame(in: .global).origin.y)
                }
                .frame(height: 0)
                if onRefresh != nil {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(width: Constants.ProgressViewHeight, height: viewModel.isRefreshing ? Constants.ProgressViewHeight : max(Constants.ProgressViewHeight * viewModel.process, 0), alignment: .center)
                        .clipped()
                        .offset(y: -(viewModel.offsetY ?? 0) + viewModel.initialOffsetY)
                }
                content()
            }
        }
        .onPreferenceChange(RefreshScrollViewPreferenceKey.self) { value in
            if let _ = viewModel.offsetY {
                offsetChanged?(value - viewModel.initialOffsetY)
            }
            viewModel.didUpdateOffsetY(value)
        }
        .onChange(of: viewModel.isRefreshing) { isRefresh in
            guard isRefresh else { return }
            Task { @MainActor in
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
    private let triggerRefresh: CGFloat = Constants.triggerRefreshHeight
    @Published var isRefreshing: Bool = false
    @Published var process: CGFloat = 0.0

    @MainActor
    func didUpdateOffsetY(_ value: CGFloat) {
        if let _ = offsetY {
            let difference = value - initialOffsetY
            let process = min(max(difference, 0), triggerRefresh) / triggerRefresh
            self.process = process
            self.offsetY = value
            if !isRefreshing,
               difference > triggerRefresh {
                isRefreshing = true
            }
        } else {
            self.offsetY = value
            self.initialOffsetY = value
        }
    }
}
