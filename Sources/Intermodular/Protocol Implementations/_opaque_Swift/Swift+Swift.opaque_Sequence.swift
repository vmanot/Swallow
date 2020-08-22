//
// Copyright (c) Vatsal Manot
//

import Swift

extension AnySequence: _opaque_Sequence {

}

extension EnumeratedSequence: _opaque_Sequence {
    
}

extension IteratorSequence: _opaque_Sequence {
    
}

extension JoinedSequence: _opaque_Sequence {
    
}

extension LazySequence: _opaque_Sequence {
    public func _opaque_Sequence_makeIterator() -> _opaque_IteratorProtocol {
        return makeIterator().iteratorOnly
    }
}

extension Set: _opaque_Sequence {
    
}

extension Slice: _opaque_Sequence {
    
}

extension UnfoldSequence: _opaque_Sequence {
    
}

extension Zip2Sequence: _opaque_Sequence {
    public func _opaque_Sequence_makeIterator() -> _opaque_IteratorProtocol {
        return makeIterator().iteratorOnly
    }
}
