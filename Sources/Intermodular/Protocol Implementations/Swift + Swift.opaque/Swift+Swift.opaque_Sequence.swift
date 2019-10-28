//
// Copyright (c) Vatsal Manot
//

import Swift

extension AnySequence: opaque_Sequence {

}

extension EnumeratedSequence: opaque_Sequence {
    
}

extension IteratorSequence: opaque_Sequence {
    
}

extension JoinedSequence: opaque_Sequence {
    
}

extension LazySequence: opaque_Sequence {
    public func opaque_Sequence_makeIterator() -> opaque_IteratorProtocol {
        return makeIterator().iteratorOnly
    }
}

extension Set: opaque_Sequence {
    
}

extension Slice: opaque_Sequence {
    
}

extension UnfoldSequence: opaque_Sequence {
    
}

extension Zip2Sequence: opaque_Sequence {
    public func opaque_Sequence_makeIterator() -> opaque_IteratorProtocol {
        return makeIterator().iteratorOnly
    }
}
