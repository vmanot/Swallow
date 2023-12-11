//
// Copyright (c) Vatsal Manot
//

import Swallow

/// A priority queue.
public struct PriorityQueue<T: Comparable> {
    public typealias Element = T
    public typealias SubSequence = Value.SubSequence
    public typealias Index = Value.Index
    public typealias Value = [Element]
    
    public var value = [Element]()
    private let predicate: ((Element, Element) -> Bool)

    public init(
        _ value: [Element]
    ) {
        self.value = value
        self.predicate = { $0 < $1 }
    }
    
    public init(
        ascending: Bool = false,
        startingValues: [Element] = []
    ) {
        self.init(
            order: ascending ? { (x: T, y: T) in x > y } : { (x: T, y: T) in x < y },
            startingValues: startingValues
        )
    }

    public init(
        order: @escaping (Element, Element) -> Bool,
        startingValues: [Element] = []
    ) {
        predicate = order
        value = startingValues
        
        var i = (value.count / 2) - 1
        
        while i >= 0 {
            sink(i)
            i -= 1
        }
    }
    
    private mutating func sink(_ index: Int) {
        var index = index
        
        while 2 * index + 1 < value.count {
            var j = 2 * index + 1
            
            if j < (value.count - 1) && predicate(value[j], value[j + 1]) {
                j += 1

            }

            if !predicate(value[index], value[j]) {
                break
            }
            
            value.swapAt(index, j)
            
            index = j
        }
    }
    
    private mutating func swim(_ index: Int) {
        var index = index
        
        while index > 0 && predicate(value[(index - 1) / 2], value[index]) {
            value.swapAt((index - 1) / 2, index)
            index = (index - 1) / 2
        }
    }
}

// MARK: - Conformances

extension PriorityQueue: Collection {
    public var startIndex: Int {
        value.startIndex
    }
    
    public var endIndex: Int {
        value.endIndex
    }
    
    public subscript(position: Int) -> Element {
        value[position]
    }
    
    public subscript(bounds: Range<Int>) -> Array<Element>.SubSequence {
        value[bounds]
    }
}

extension PriorityQueue: IteratorProtocol {
    mutating public func next() -> Element? {
        return pop()
    }
}

extension PriorityQueue: QueueProtocol {
    /// - Complexity: O(lg n)
    public mutating func enqueue(_ element: Element) {
        value.append(element)
        
        swim(value.count - 1)
    }
    
    /// - Complexity: O(lg n)
    public mutating func dequeue() -> Element? {
        guard !value.isEmpty else {
            return nil
        }
        
        guard value.count != 1 else {
            return value.removeFirst()
        }
        
        value.swapAt(0, value.count - 1)
        
        defer {
            sink(0)
        }
        
        return value.removeLast()
    }
}

extension PriorityQueue: Poppable {
    public func peek() -> Element? {
        return value.first
    }
    
    public mutating func pop() -> Element? {
        return dequeue()
    }
}

extension PriorityQueue: Sequence {
    public typealias Iterator = PriorityQueue
    
    public func makeIterator() -> Iterator {
        return self
    }
}

extension PriorityQueue {
    /// - Complexity: O(n)
    @discardableResult
    public mutating func remove(_ item: Element) -> Element? {
        guard let index = value.firstIndex(of: item) else {
            return nil
        }
        
        value.swapAt(index, value.count - 1)
        value.removeLast()
        
        swim(index)
        sink(index)
        
        return item
    }
    
    /// - Complexity: O(n)
    public mutating func removeAll(of item: Element) {
        var lastCount = value.count
        
        remove(item)
        
        while (value.count < lastCount) {
            lastCount = value.count
            
            remove(item)
        }
    }
    
    public mutating func removeAll() {
        value.removeAll(keepingCapacity: false)
    }
}
