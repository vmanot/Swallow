//
// Copyright (c) Vatsal Manot
//

import Swift

extension Collection {
    public typealias _EnumeratedSequence = Zip2Sequence<Self.Indices, Self>
    
    @_disfavoredOverload
    public func _enumerated() -> _EnumeratedSequence {
        Swift.zip(indices, self)
    }
}
