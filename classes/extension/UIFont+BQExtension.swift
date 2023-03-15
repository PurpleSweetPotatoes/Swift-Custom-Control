//
//  UIFont+BQExtension.swift
//  Pods
//  
//  Created by Bai, Payne on 2023/3/13.
//  Copyright © 2023 Garmin All rights reserved
//  

import UIKit

public enum BQFontStyle {
    case title1
    case title2
    case title3
    case body
    case callout
    case content
    case footnote
    case caption
    case custom(CGFloat, UIFont.TextStyle)

    var size: CGFloat {
        switch self {
        case .title1: return 34
        case .title2: return 28
        case .title3: return 22
        case .body: return 17
        case .callout: return 16
        case .content: return 15
        case .footnote: return 13
        case .caption: return 12
        case .custom(let size, _):
            return size
        }
    }

    var fontTextStyle: UIFont.TextStyle {
        switch self {
        case .title1: return .largeTitle
        case .title2: return .title1
        case .title3: return .title2
        case .body: return .body
        case .callout: return  .callout
        case .content: return .subheadline
        case .footnote: return .footnote
        case .caption: return .caption1
        case .custom(_, let style): return style
        }
    }
}

public extension UIFont {
    static func dynamic(_ style: BQFontStyle, weight: UIFont.Weight = .regular, maxScaleSize: CGFloat = 2) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: style.size, weight: weight)
        let metrics = UIFontMetrics(forTextStyle: style.fontTextStyle)
        return metrics.scaledFont(for: systemFont, maximumPointSize: style.size * maxScaleSize)
    }
}
