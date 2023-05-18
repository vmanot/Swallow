//
// Copyright (c) Vatsal Manot
//

import Swallow

public struct Queue<T>: QueueProtocol {
    private let resizeFactor = 2
    private let initialCapacity: Int
    
    private var storage: ContiguousArray<T?>
    private var pushNextIndex = 0
    
    public private(set) var count = 0
    
    public init(capacity: Int) {
        initialCapacity = capacity
        storage = .init(repeating: nil, count: capacity)
    }
    
    private var dequeueIndex: Int {
        let index = pushNextIndex - count
        return index < 0 ? index + storage.count : index
    }
    
    public var isEmpty: Bool {
        return count == 0
    }
    
    mutating private func resizeTo(_ size: Int) {
        var newStorage = ContiguousArray<T?>(repeating: nil, count: size)
        
        let dequeueIndex = self.dequeueIndex
        let spaceToEndOfQueue = storage.count - dequeueIndex
        
        // first batch is from dequeue index to end of array
        let countElementsInFirstBatch = Swift.min(count, spaceToEndOfQueue)
        // second batch is wrapped from start of array to end of queue
        let numberOfElementsInSecondBatch = count - countElementsInFirstBatch
        
        newStorage[0 ..< countElementsInFirstBatch] = storage[dequeueIndex ..< (dequeueIndex + countElementsInFirstBatch)]
        newStorage[countElementsInFirstBatch ..< (countElementsInFirstBatch + numberOfElementsInSecondBatch)] = storage[0 ..< numberOfElementsInSecondBatch]
        
        pushNextIndex = count
        storage = newStorage
    }
    
    public func peek() -> T? {
        return count > 0 ? storage[dequeueIndex]! : nil
    }
    
    public mutating func enqueue(_ element: T) {
        if count == storage.count {
            resizeTo(Swift.max(storage.count, 1) * resizeFactor)
        }
        
        storage[pushNextIndex] = element
        pushNextIndex += 1
        count += 1
        
        if pushNextIndex >= storage.count {
            pushNextIndex -= storage.count
        }
    }
    
    private mutating func dequeueElementOnly() -> T {
        precondition(count > 0)
        
        let index = dequeueIndex
        
        defer {
            storage[index] = nil
            count -= 1
        }
        
        return storage[index]!
    }
    
    public mutating func dequeue() -> T? {
        if self.count == 0 {
            return nil
        }
        
        defer {
            let downsizeLimit = storage.count / (resizeFactor * resizeFactor)
            if count < downsizeLimit && downsizeLimit >= initialCapacity {
                resizeTo(storage.count / resizeFactor)
            }
        }
        
        return dequeueElementOnly()
    }
}

// MARK: - Conformances

extension Queue: Sequence {
    public typealias Iterator = AnyIterator<T>
    
    public func makeIterator() -> Iterator {
        var index = dequeueIndex
        var count = self.count
        
        return AnyIterator {
            if count == 0 {
                return nil
            }
            
            defer {
                count -= 1
                index += 1
            }
            
            if index >= self.storage.count {
                index -= self.storage.count
            }
            
            return self.storage[index]
        }
    }
}
