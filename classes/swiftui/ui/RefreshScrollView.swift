//
//  RefreshScrollView.swift
//  MyTestDemo
//
//  Created by baiqiang on 2023/7/19.
//

import SwiftUI

private enum Constants {
    static let RefreshableScrollViewSpanName: String = "RefreshableScrollViewSpanName"
    static let ProgressViewHeight: CGFloat = 80
    static let TriggerRefreshHeight: CGFloat = 100
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
                        .preference(key: ScrollViewOffsetPreferenceKey.self, value: proxy.frame(in: .named(Constants.RefreshableScrollViewSpanName)).origin.y)
                }
                .frame(height: 0)
                if viewModel.isRefreshing {
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding(20)
                        .offset(y: -(viewModel.offsetY ?? 0) + viewModel.initialOffsetY)
                }
                content()
            }
            .background(GeometryReader { proxy in
                Color.clear.preference(
                    key: ScrollViewContentSizePreferenceKey.self,
                    value: proxy.size
                )
            })
        }
        
        .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
            if let _ = viewModel.offsetY {
                offsetChanged?(value - viewModel.initialOffsetY)
            }
            viewModel.didUpdateOffsetY(value)
        }
        .onPreferenceChange(ScrollViewContentSizePreferenceKey.self) { value in
            BQLogger.log("size value: \(value)")
        }
        .coordinateSpace(name: Constants.RefreshableScrollViewSpanName)
        .onChange(of: viewModel.isRefreshing) { isRefresh in
            guard isRefresh else { return }
            Task { @MainActor in
                await onRefresh?()
                viewModel.isRefreshing = false
            }
        }
    }
}

private struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}

private struct ScrollViewContentSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = CGSize.zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

private final class RefreshScrollViewModel: ObservableObject {
    var offsetY: CGFloat?
    var initialOffsetY: CGFloat = 0.0
    private let triggerRefresh: CGFloat = Constants.TriggerRefreshHeight
    @Published var isRefreshing: Bool = false
    @Published var process: CGFloat = 0.0

    @MainActor
    func didUpdateOffsetY(_ value: CGFloat) {
        if let _ = offsetY {
            let difference = value - initialOffsetY
//            let process = min(max(difference, 0), triggerRefresh) / triggerRefresh
//            self.process = process
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
