// *******************************************
//  File Name:      Array+BQExtension.swift
//  Author:         MrBai
//  Created Date:   2019/9/17 11:50 AM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import UIKit

public extension Array where Element: Equatable {
    @discardableResult
    mutating func safeRemove(ele objc: Element) -> Element? {
        if let i = firstIndex(of: objc) {
            return remove(at: i)
        }
        return nil
    }

    func random() -> Array {
        var list = self
        for index in 0 ..< list.count {
            let newIndex = Int(arc4random_uniform(UInt32(list.count - index))) + index
            if index != newIndex {
                list.swapAt(index, newIndex)
            }
        }
        return list
    }

    subscript(input: [Int]) -> ArraySlice<Element> {
        get {
            var result = ArraySlice<Element>()
            for i in input {
                assert(i < count, "Index out of range")
                result.append(self[i])
            }
            return result
        }
        set {
            for (index, i) in input.enumerated() {
                assert(i < count, "Index out of range")
                self[i] = newValue[index]
            }
        }
    }
}
