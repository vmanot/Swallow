//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _opaque_ExtensibleSequence: _opaque_Sequence {
    mutating func _opaque_ExtensibleSequence_insert(_: Any) -> Any?
    mutating func _opaque_ExtensibleSequence_insert(contentsOf _: Any) -> Any?
    mutating func _opaque_ExtensibleSequence_append(_: Any) -> Any?
    mutating func _opaque_ExtensibleSequence_append(contentsOf _: Any) -> Any?
}

public protocol _opaque_ExtensibleCollection: _opaque_Collection, _opaque_ExtensibleSequence {
    
}

public protocol _opaque_ExtensibleRangeReplaceableCollection: _opaque_ExtensibleCollection, _opaque_RangeReplaceableCollection {
    
}
