//
//  OffsetScrollView.swift
//  Pods
//  
//  Created by Bai, Payne on 2023/4/3.
//  Copyright © 2023 Garmin All rights reserved
//  

import SwiftUI

public struct OffsetScrollView<T: View>: View {
    public let axes: Axis.Set
    public let showsIndicator: Bool
    public let onOffsetChanged: (CGPoint) -> Void
    let content: T
    private let kScrollViewOrigin = "ScrollViewOrigin"

    public init(axes: Axis.Set = .vertical,
         showsIndicator: Bool = false,
         onOffsetChanged: @escaping (CGPoint) -> Void,
         @ViewBuilder content: () -> T) {
        self.axes = axes
        self.showsIndicator = showsIndicator
        self.onOffsetChanged = onOffsetChanged
        self.content = content()
    }

    public var body: some View {
        ScrollView(axes, showsIndicators: showsIndicator) {
            GeometryReader { proxy in
                Color.clear.preference(key: OffsetPreferenceKey.self,
                                       value: proxy.frame(in: .named(kScrollViewOrigin)).origin
                )
            }.frame(width: 0, height: 0)
            content
        }
        .coordinateSpace(name: kScrollViewOrigin)
        .onPreferenceChange(OffsetPreferenceKey.self, perform: onOffsetChanged)
    }
}

private struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}
