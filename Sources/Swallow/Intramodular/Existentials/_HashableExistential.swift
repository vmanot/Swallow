//
// Copyright (c) Vatsal Manot
//

import Swift

@propertyWrapper
public struct _HashableExistential<Value>: PropertyWrapper {
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
    
    public var projectedValue: Self {
        self
    }
    
    public init(wrappedValue: Value) {
        Self._validate(wrappedValue)
        
        self.base = wrappedValue
    }
    
    private static func _validate(_ value: Value) {
        guard !(value is _HashablePlaceholderNil) else {
            return
        }
        
        switch value {
            case is any Hashable:
                break
            case is Any.Type:
                break
            case is Void:
                break
            case is _HashablePlaceholderNil:
                break
            default:
                guard _isValueNil(value) else {
                    return
                }
                
                assertionFailure()
        }
    }
}

extension _HashableExistential {
    fileprivate enum InitializationError: Error {
        case unsupportedValue(Any)
    }
    
    @_disfavoredOverload
    public init(erasing value: Any) throws where Value == any Hashable {
        switch value {
            case let value as any Hashable:
                self.init(wrappedValue: value)
            case let value as Any.Type:
                self.init(wrappedValue: ObjectIdentifier(value))
            case is Void:
                self.init(wrappedValue: None())
            default:
                if _isValueNil(value) {
                    // TODO: Assert value is an existential type.
                    self.init(wrappedValue: _HashablePlaceholderNil())
                } else {
                    throw InitializationError.unsupportedValue(value)
                }
        }
    }
}

// MARK: - Conformances

extension _HashableExistential: CustomStringConvertible {
    public var description: String {
        String(describing: wrappedValue)
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
        if let base = base as? None {
            hasher.combine(base)
        } else if let base = base as? _HashablePlaceholderNil {
            hasher.combine(base)
        } else if let base = base as? Any.Type {
            ObjectIdentifier(base).hash(into: &hasher)
        } else if let base = base as? (any Hashable) {
            hasher.combine(ObjectIdentifier(type(of: base)))
            hasher.combine(base)
        } else {
            if _isValueNil(base) {
                _HashablePlaceholderNil().hash(into: &hasher)
            } else if base is Void {
                hasher.combine(None())
            } else {
                assertionFailure("unsupported type \(type(of: base))")
            }
        }
    }
}

extension _HashableExistential: @unchecked Sendable {
    
}

// MARK: - Auxiliary

extension _HashableExistential {
    fileprivate struct _HashablePlaceholderNil: ExpressibleByNilLiteral, Hashable, Sendable {
        init() {
            
        }
        
        init(nilLiteral: ()) {
            self.init()
        }
    }
}

public struct _TypeHashingAnyHashable: Hashable, _UnwrappableHashableTypeEraser {
    private let _base: AnyHashable
    
    public var base: any Hashable {
        _base.base as! (any Hashable)
    }
    
    public init<H: Hashable>(_ base: H) {
        self._base = AnyHashable(base)
    }
    
    public init(_erasing base: any Hashable) {
        self = base._eraseToTypeHashingAnyHashable()
    }
    
    public func _unwrapBase() -> _UnwrappedBaseType {
        base
    }
        
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(type(of: _base.base)))
        hasher.combine(_base)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard type(of: lhs._base.base) == type(of: rhs._base.base) else {
            return false
        }
        
        return rhs._base == lhs._base
    }
}

extension Hashable {
    public func _eraseToTypeHashingAnyHashable() -> _TypeHashingAnyHashable {
        _TypeHashingAnyHashable(self)
    }
}
