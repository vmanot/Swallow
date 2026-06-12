//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol _CPlusPlusUnion {
    associatedtype RawValue
    
    var rawValue: RawValue { get set }
}

extension _CPlusPlusUnion {
    @inlinable
    public mutating func bind<T>() -> UnsafeMutablePointer<T> {
        return withUnsafePointer(to: &self) { pointer in
            return pointer.rawRepresentation.assumingMemoryBound(to: T.self).mutableRepresentation
        }
    }
}
