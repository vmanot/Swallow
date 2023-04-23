//
// Copyright (c) Vatsal Manot
//

import Swift

@propertyWrapper
public struct _HashableExistential<Value> {
    private var base: Value
    
    public var wrappedValue: Value {
        get {
            self.base
        } set {
            self.base = newValue
        }
    }
    
    public init(wrappedValue: Value) {
        self.base = wrappedValue
    }
    
    public init?(erasing value: Any) where Value == any Hashable {
        if let value = value as? (any Hashable) {
            self.init(erasing: value)
        } else if let value = value as? Any.Type {
            self.init(erasing: value)
        } else {
            assertionFailure("Unsupported value: \(value)")
            
            return nil
        }
    }
    
    public init(erasing value: any Hashable) where Value == any Hashable {
        self.base = value
    }
    
    public init(erasing value: Any.Type) where Value == any Hashable {
        self.base = ObjectIdentifier(value)
    }
}

extension _HashableExistential: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard type(of: lhs.base) == type(of: rhs.base) else {
            assert(!AnyEquatable.equate(lhs.base, rhs.base))
            
            return false
        }
        
        return AnyEquatable.equate(lhs.base, rhs.base)
    }
}

extension _HashableExistential: Hashable {
    public func hash(into hasher: inout Hasher) {
        if let base = base as? Any.Type {
            ObjectIdentifier(base).hash(into: &hasher)
            
            return
        }
        
        guard let base = base as? (any Hashable) else {
            assertionFailure()
            
            return
        }
        
        hasher.combine(ObjectIdentifier(type(of: base)))
        hasher.combine(base)
    }
}

extension _HashableExistential: @unchecked Sendable {
    
}
