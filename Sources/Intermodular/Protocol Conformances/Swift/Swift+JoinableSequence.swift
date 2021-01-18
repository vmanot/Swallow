//
// Copyright (c) Vatsal Manot
//

import Swift

extension CollectionOfOne: JoinableCollection {
    public typealias JointSequenceType = Join2Collection<CollectionOfOne, CollectionOfOne>
}

extension ContiguousArray: JoinableCollection {
    
}

extension Set: JoinableSequence {
    public typealias JointSequenceType = Join2Sequence<Set, Set>
}

extension UnsafeBufferPointer: JoinableCollection {
    
}

extension UnsafeMutableBufferPointer: JoinableCollection {
    
}

extension UnsafeRawBufferPointer: JoinableCollection {
    
}

extension UnsafeMutableRawBufferPointer: JoinableCollection {
    
}
