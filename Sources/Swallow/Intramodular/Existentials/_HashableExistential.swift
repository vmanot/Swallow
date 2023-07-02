//
// Copyright (c) Vatsal Manot
//

import Swift

@propertyWrapper
public struct _HashableExistential<Value>: PropertyWrapper {
    struct _HashablePlaceholderNil: ExpressibleByNilLiteral, Hashable, Sendable {
        init() {
            
        }
        
        init(nilLiteral: ()) {
            self.init()
        }
    }
    
    private var base: Value
    
    public var wrappedValue: Value {
        get {
            if base is _HashablePlaceholderNil {
                do {
                    return try _initializeNilLiteral(ofType: Value.self)
                } catch {
                    assertionFailure(error)
                    
                    return base
                }
            } else {
                return self.base
            }
        } set {
            self.base = newValue
        }
    }
        
    public init(wrappedValue: Value) {
        Self._validate(wrappedValue)
        
        self.base = wrappedValue
    }
    
    public init(_unsafelyErasing base: Any) {
        self.base = base as! Value
    }
    
    public init(_unsafelyErasing base: Any) where Value == any Hashable {
        self.base = base as! Value
    }
    
    @_disfavoredOverload
    public init?(erasing value: Any) where Value == any Hashable {
        if let value = value as? (any Hashable) {
            self.init(erasing: value)
        } else if let value = value as? Any.Type {
            self.init(erasing: value)
        } else if _isValueNil(value) {
            self.init(erasing: _HashablePlaceholderNil())
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
    
    static func _validate(_ value: Value) {
        guard !(value is _HashablePlaceholderNil) else {
            return
        }
        
        guard value is any Hashable || value is Any.Type else {
            if _isValueNil(value) {
                return
            } else {
                assertionFailure()
                
                return
            }
        }
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
        } else if let base = base as? (any Hashable) {
            hasher.combine(ObjectIdentifier(type(of: base)))
            hasher.combine(base)
        } else if _isValueNil(base) {
            _HashablePlaceholderNil().hash(into: &hasher)
        } else {
            assertionFailure("unsupported type \(type(of: base))")
        }
    }
}

extension _HashableExistential: @unchecked Sendable {
    
}
