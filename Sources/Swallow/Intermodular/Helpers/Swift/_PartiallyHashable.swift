//
// Copyright (c) Vatsal Manot
//

import Swift

/// Provides a fast path for testing inequality for partially hashable data types.`
public protocol _PartiallyHashable {
    func _partialHash(into hasher: inout Hasher)
}

extension _PartiallyHashable {
    public var _partialHashValue: Int {
        @_transparent
        get {
            var hasher = Hasher()
            
            _partialHash(into: &hasher)
            
            return hasher.finalize()
        }
    }
}
