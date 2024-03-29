//
//  DoughnutView.swift
//  BQSwiftKit
//
//  Created by baiqiang on 2023/6/14.
//

import SwiftUI

public protocol DoughnutViewData {
    var lineWidth: CGFloat { get }
    var progress: CGFloat { get }
    var emptyColor: Color { get }
    var progressColor: Color { get }
}

public struct DoughnutView<Content: View>: View {
    let data: DoughnutViewData
    let insideView: () -> Content

    public init(data: DoughnutViewData, insideView: @escaping () -> Content) {
        self.data = data
        self.insideView = insideView
    }

    public var body: some View {
        Circle()
            .stroke(style: StrokeStyle(lineWidth: data.lineWidth))
            .foregroundColor(data.emptyColor)
            .frame(width: .infinity, height: .infinity)
            .overlay {
                Circle()
                    .trim(from: 0, to: data.progress)
                    .stroke(style: StrokeStyle(lineWidth: data.lineWidth))
                    .foregroundColor(data.progressColor)
                    .rotationEffect(.degrees(-90))
            }
            .overlay {
                insideView()
                    .padding(data.lineWidth)
            }
    }
}
