//
//  BQLRUCache.swift
//  BQSwiftKit
//
//  Created by baiqiang on 2023/7/20.
//

import Foundation

public final class BQLRUCache<Key: Hashable, Value> where Key: Comparable {
    /// configured with Double Linked-list.
    private class ListNode {
        var key: Key?
        var value: Value?
        var prevNode: ListNode?
        var nextNode: ListNode?

        init(key: Key? = nil, value: Value? = nil) {
            self.key = key
            self.value = value
        }
    }

    /// Use Dictionary for fast search.
    private var nodeDictionary = [Key: ListNode]()

    /// Cache's limit count.
    private var capacity = 0

    /// head's nextNode is the actual first node in the Double Linked-list.
    private var head = ListNode()

    /// tail's prevNode is the actual last node in the Double Linked-list.
    private var tail = ListNode()

    /// initialized with empty Double Linked-list.
    public init(capacity: Int) {
        self.capacity = capacity
        head.nextNode = tail
        tail.prevNode = head
    }

    /// Push your value and if there is same value, remove that automatically.
    /// if not, and the capacity of LRUCache full, remove Least Recently Used Node and push new node.
    public func setValue(value: Value, forKey key: Key) {
        let newNode = ListNode(key: key, value: value)

        if let oldNode = nodeDictionary[key] {
            remove(node: oldNode)
        } else if nodeDictionary.count >= capacity,
                  let tailNode = tail.prevNode {
            remove(node: tailNode) // remove Least Recently Used Node
        }
        insertToHead(node: newNode)
    }

    /// When the cache hit happen, remove the node what you get and insert to Head side again.
    public func getValue(forKey key: Key) -> Value? {
        guard let node = nodeDictionary[key] else { return nil }
        remove(node: node)
        insertToHead(node: node)
        return node.value
    }

    /// Remove Node in the Double Linked-list.
    private func remove(node: ListNode) {
        node.prevNode?.nextNode = node.nextNode
        node.nextNode?.prevNode = node.prevNode
        guard let key = node.key else { return }
        nodeDictionary.removeValue(forKey: key)
    }

    /// insertion is always fullfilled on the Head side.
    private func insertToHead(node: ListNode) {
        head.nextNode?.prevNode = node
        node.nextNode = head.nextNode
        node.prevNode = head
        head.nextNode = node
        guard let key = node.key else { return }
        nodeDictionary.updateValue(node, forKey: key)
    }

    /// Print values in Cache sorted by key
    public func description() {
        let values = nodeDictionary.sorted(by: {$0.0 < $1.0}).map{ $0.value }
        values.forEach({
            BQLogger.log($0.value.debugDescription)
        })
    }
}
