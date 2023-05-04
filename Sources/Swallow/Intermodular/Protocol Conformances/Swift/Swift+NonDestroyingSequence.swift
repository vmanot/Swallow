//
// Copyright (c) Vatsal Manot
//

import Swift

extension Array: NonDestroyingMutableRandomAccessCollection {
    @inlinable
    public var nonDestructiveCount: Int {
        count
    }
}

extension ContiguousArray: NonDestroyingMutableRandomAccessCollection {
    @inlinable
    public var nonDestructiveCount: Int {
        count
    }
}

extension CollectionOfOne: NonDestroyingMutableRandomAccessCollection {
    @inlinable
    public var nonDestructiveCount: Int {
        count
    }
}

extension Dictionary: NonDestroyingCollection {
    @inlinable
    public var nonDestructiveCount: Int {
        count
    }
}

extension Set: NonDestroyingSequence {
    @inlinable
    public var nonDestructiveCount: Int {
        count
    }
}

extension String: NonDestroyingBidirectionalCollection {
    @inlinable
    public var nonDestructiveCount: Int {
        count
    }
}

extension String.UnicodeScalarView: NonDestroyingBidirectionalCollection {
    @inlinable
    public var nonDestructiveCount: Int {
        count
    }
}

extension Substring: NonDestroyingBidirectionalCollection {
    @inlinable
    public var nonDestructiveCount: Int {
        count
    }
}

extension UnsafeBufferPointer: NonDestroyingRandomAccessCollection {
    @inlinable
    public var nonDestructiveCount: Int {
        count
    }
}

extension UnsafeMutableBufferPointer: NonDestroyingMutableRandomAccessCollection {
    @inlinable
    public var nonDestructiveCount: Int {
        count
    }
}

extension UnsafeRawBufferPointer: NonDestroyingRandomAccessCollection {
    @inlinable
    public var nonDestructiveCount: Int {
        count
    }
}

extension UnsafeMutableRawBufferPointer: NonDestroyingMutableRandomAccessCollection {
    @inlinable
    public var nonDestructiveCount: Int {
        count
    }
}
