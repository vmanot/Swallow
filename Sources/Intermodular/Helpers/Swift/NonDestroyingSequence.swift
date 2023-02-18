//
// Copyright (c) Vatsal Manot
//

import Swift

/// A sequence type that is guaranteed to be non-destroying.
public protocol NonDestroyingSequence: Countable, Sequence {
    var nonDestructiveCount: Count { get }
    
    var isEmpty: Bool { get }
}

public protocol NonDestroyingCollection: Collection, NonDestroyingSequence {
    
}

public protocol NonDestroyingMutableCollection: NonDestroyingMutableSequence, NonDestroyingCollection {
    
}

public protocol NonDestroyingBidirectionalCollection: BidirectionalCollection, NonDestroyingCollection {
    
}

public protocol NonDestroyingMutableBidirectionalCollection: NonDestroyingMutableSequence, NonDestroyingBidirectionalCollection {
    
}

public protocol NonDestroyingRandomAccessCollection: NonDestroyingBidirectionalCollection, RandomAccessCollection {
    
}

public protocol NonDestroyingMutableRandomAccessCollection: NonDestroyingMutableSequence, NonDestroyingRandomAccessCollection {
    
}

// MARK: - Implementation

public protocol NonDestroyingMutableSequence: MutableSequence, NonDestroyingSequence {
    
}
