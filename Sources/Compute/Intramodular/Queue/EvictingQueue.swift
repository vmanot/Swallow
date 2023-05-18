//
// Copyright (c) Vatsal Manot
//

import Swallow

/// A prioritiy queue that evicts elements after a certain count.
public struct EvictingQueue<Element>: QueueProtocol, Sequence {
    private var storage: Queue<Element>
    private var size: Int?

    public var count: Int {
        return storage.count
    }

    public init(size: Int?) {
        self.storage = .init(capacity: size ?? 0)
        self.size = size
    }

    public mutating func enqueue(_ element: Element) {
        storage.enqueue(element)

        if storage.count > (size ?? Int.maximum) {
            _ = dequeue()
        }
    }

    public mutating func dequeue() -> Element? {
        return storage.dequeue()
    }

    public typealias Iterator = Queue<Element>.Iterator

    public func makeIterator() -> Iterator {
        return storage.makeIterator()
    }
}
