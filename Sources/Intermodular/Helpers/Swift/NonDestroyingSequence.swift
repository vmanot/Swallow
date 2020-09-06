//
// Copyright (c) Vatsal Manot
//

import Swift

///
///A sequence type that is guaranteed to be non-destroying.
///
public protocol NonDestroyingSequence: Countable, Sequence {
    associatedtype CollectionCounterpart: Collection = SequenceToCollection<Self>
    associatedtype BidirectionalCollectionCounterpart: BidirectionalCollection = SequenceToCollection<Self>
    associatedtype RandomAccessCollectionCounterpart: RandomAccessCollection = SequenceToCollection<Self>

    var collectionCounterpart: CollectionCounterpart { get }
    var bidirectionalCollectionCounterpart: BidirectionalCollectionCounterpart { get }
    var randomAccessCollectionCounterpart: RandomAccessCollectionCounterpart { get }
    
    var nonDestructiveCount: Count { get }
    
    var isEmpty: Bool { get }
}

public protocol NonDestroyingCollection: Collection, NonDestroyingSequence {
    associatedtype CollectionCounterpart = Self
}

public protocol NonDestroyingMutableCollection: NonDestroyingMutableSequence, NonDestroyingCollection {
    
}

public protocol NonDestroyingBidirectionalCollection: BidirectionalCollection2, NonDestroyingCollection {
    associatedtype BidirectionalCollection = Self
}

public protocol NonDestroyingMutableBidirectionalCollection: NonDestroyingMutableSequence, NonDestroyingBidirectionalCollection {
    
}

public protocol NonDestroyingRandomAccessCollection: NonDestroyingBidirectionalCollection, RandomAccessCollection2 {
    associatedtype RandomAccessCollectionCounterpart = Self
}

public protocol NonDestroyingMutableRandomAccessCollection: NonDestroyingMutableSequence, NonDestroyingRandomAccessCollection {
    
}

// MARK: - Implementation -

extension NonDestroyingSequence {
    @inlinable
    public var nonDestructiveCount: Int {
        return collectionCounterpart.count
    }
}

extension NonDestroyingSequence where Self: ResizableCollection {
    @inlinable
    public var isEmpty: Bool {
        return collectionCounterpart.isEmpty
    }
}

extension NonDestroyingSequence where CollectionCounterpart == Self {
    @inlinable
    public var collectionCounterpart: CollectionCounterpart {
        get {
            return self
        } set {
            self = newValue
        }
    }
}

extension NonDestroyingSequence where CollectionCounterpart: Wrapper, CollectionCounterpart.Value == Self {
    @inlinable
    public var collectionCounterpart: CollectionCounterpart {
        get {
            return .init(self)
        } set {
            self = newValue.value
        }
    }
}

extension NonDestroyingSequence where BidirectionalCollectionCounterpart == Self {
    @inlinable
    public var bidirectionalCollectionCounterpart: BidirectionalCollectionCounterpart {
        get {
            return self
        } set {
            self = newValue
        }
    }
}

extension NonDestroyingSequence where BidirectionalCollectionCounterpart: Wrapper, BidirectionalCollectionCounterpart.Value == Self {
    @inlinable
    public var bidirectionalCollectionCounterpart: BidirectionalCollectionCounterpart {
        get {
            return .init(self)
        } set {
            self = newValue.value
        }
    }
}

extension NonDestroyingSequence where RandomAccessCollectionCounterpart == Self {
    @inlinable
    public var randomAccessCollectionCounterpart: RandomAccessCollectionCounterpart {
        get {
            return self
        } set {
            self = newValue
        }
    }
}

extension NonDestroyingSequence where RandomAccessCollectionCounterpart: Wrapper, RandomAccessCollectionCounterpart.Value == Self {
    @inlinable
    public var randomAccessCollectionCounterpart: RandomAccessCollectionCounterpart {
        get {
            return .init(self)
        } set {
            self = newValue.value
        }
    }
}

public protocol NonDestroyingMutableSequence: MutableSequence, NonDestroyingSequence where CollectionCounterpart: MutableCollection, BidirectionalCollectionCounterpart: MutableCollection, RandomAccessCollectionCounterpart: MutableCollection {

}
