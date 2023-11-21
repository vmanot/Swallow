//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

public struct _ReferenceConvertibleGuts<Base: NSObject & NSCopying> {
    private var value: Base
    
    public mutating func knownUniquelyReferencedValue() -> Base {
        if !isKnownUniquelyReferenced(&value) {
            value = value.copy() as! Base
        }
        
        return value
    }
}

@frozen
public enum Mutable_ReferenceConvertibleGuts<Base: MutableRepresentationConvertible & NSObject & NSCopying> where Base.MutableRepresentation: NSObject & NSCopying {
    case immutable(Base)
    case mutable(Base.MutableRepresentation)
    
    @inlinable
    public var immutableValue: Base {
        switch self {
            case let .immutable(value):
                return value
            case let .mutable(value):
                return value as! Base
        }
    }
    
    @inlinable
    public mutating func uniqueMutableValue() -> Base.MutableRepresentation {
        if case var .mutable(value) = self, isKnownUniquelyReferenced(&value) {
            return value
        }
        
        let newValue = immutableValue.mutableCopy() as! Base.MutableRepresentation
        self = .mutable(newValue)
        
        return newValue
    }
}
