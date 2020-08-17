//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _opaque_DestructivelyMutableSequence: _opaque_MutableSequence {
    mutating func _opaque_DestructivelyMutableSequence_forEach<T>(mutating iterator: ((inout Any?) throws -> T)) rethrows
}
