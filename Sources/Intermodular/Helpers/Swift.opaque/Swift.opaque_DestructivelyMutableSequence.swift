//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol opaque_DestructivelyMutableSequence: opaque_MutableSequence {
    mutating func opaque_DestructivelyMutableSequence_forEach<T>(mutating iterator: ((inout Any?) throws -> T)) rethrows
}
