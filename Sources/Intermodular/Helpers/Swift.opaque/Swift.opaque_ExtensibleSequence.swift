//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol opaque_ExtensibleSequence: opaque_Sequence {
    mutating func opaque_ExtensibleSequence_insert(_: Any) -> Any?
    mutating func opaque_ExtensibleSequence_insert(contentsOf _: Any) -> Any?
    mutating func opaque_ExtensibleSequence_append(_: Any) -> Any?
    mutating func opaque_ExtensibleSequence_append(contentsOf _: Any) -> Any?
}

public protocol opaque_ExtensibleCollection: opaque_Collection, opaque_ExtensibleSequence {
    
}

public protocol opaque_ExtensibleRangeReplaceableCollection: opaque_ExtensibleCollection, opaque_RangeReplaceableCollection {
    
}
