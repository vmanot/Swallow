//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _opaque_MutableSequence: _opaque_Sequence {
    mutating func _opaque_MutableSequence_forEach<T>(mutating iterator: ((inout Any) throws -> T)) rethrows
}
