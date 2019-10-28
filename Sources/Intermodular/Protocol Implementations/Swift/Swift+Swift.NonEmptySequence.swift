//
// Copyright (c) Vatsal Manot
//

import Swift

extension CollectionOfOne: NonEmptySequence {
    public var first: Element {
        return self[0]
    }
    
    public var last: Element {
        return self[0]
    }
}

extension Join2Collection: NonEmptySequence where C0: NonEmptySequence, C1: NonEmptySequence {
    public var first: Element {
        return value.0.first
    }

    public var last: Element {
        return value.1.last
    }
}
