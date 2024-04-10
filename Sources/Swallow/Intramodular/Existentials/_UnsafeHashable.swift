//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _UnsafeHashable {
    func _unsafelyHash(into hasher: inout Hasher) throws
}

// MARK: - Implemented Conformances

extension HeterogeneousDictionary: _UnsafeHashable {
    public func _unsafelyHash(into hasher: inout Hasher) throws {
        try storage.mapValues({ try _HashableExistential(erasing: $0) }).hash(into: &hasher)
    }
}
