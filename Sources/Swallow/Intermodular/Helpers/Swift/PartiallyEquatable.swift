//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type that can be tested for maybe-known inequality.
///
/// This type is **internal**.
public protocol _PartiallyEquatable {
    func isEqual(to _: Self) -> Bool?
}

/// This type is **internal**.
public protocol _PartialEquatableTypeConvertible {
    associatedtype PartialEquatableType: _PartiallyEquatable
    
    var _partialEquatableView: PartialEquatableType { get }
}

// MARK: - Supplementary

public func _isKnownEqual<T: _PartialEquatableTypeConvertible>(
    _ lhs: T,
    _ rhs: T
) -> Bool {
    guard let isEqual = lhs._partialEquatableView.isEqual(to: rhs._partialEquatableView) else {
        return false
    }
    
    return isEqual
}

// MARK: - Internal

extension Dictionary: _PartialEquatableTypeConvertible {
    public var _partialEquatableView: _PartiallyEquatableDictionary<Key, Value> {
        @_transparent
        get {
            _PartiallyEquatableDictionary(base: self)
        }
    }
}

public struct _PartiallyEquatableDictionary<Key: Hashable, Value>: _PartiallyEquatable {
    public let base: [Key: Value]
    
    public init(base: [Key: Value]) {
        self.base = base
    }
    
    public func isEqual(to other: Self) -> Bool? {
        guard base.count == other.base.count else {
            return false
        }
        
        guard base.keys == other.base.keys else {
            return false
        }
        
        for key in base.keys {
            guard let lhs = base[key], let rhs = other.base[key] else {
                assertionFailure()
                
                return false
            }
            
            if _isMaybeEqual(lhs, rhs) == false {
                return false
            }
        }
        
        return nil
    }
}

@frozen
public struct _MaybeEquatable<Base>: _PartiallyEquatable {
    @usableFromInline
    let base: Base
    
    @_transparent
    public init(base: Base) {
        self.base = base
    }
    
    @_transparent
    public func isEqual(to other: Self) -> Bool? {
        _isMaybeEqual(base, other.base)
    }
}

@_transparent
public func _isMaybeEqual(_ lhs: Any, _ rhs: Any) -> Bool? {
    func open<LHS>(_: LHS.Type) -> Bool? {
        (MutableValueBox<LHS>.self as? _MaybeEquatableProtocol.Type)?.isEqual(lhs, rhs)
    }
    
    let isEqual = _openExistential(type(of: lhs), do: open)
    
    guard let isEqual else {
        return nil
    }
    
    return isEqual
}

@usableFromInline
protocol _MaybeEquatableProtocol {
    static func isEqual(_ lhs: Any, _ rhs: Any) -> Bool
}

extension MutableValueBox: _MaybeEquatableProtocol where WrappedValue: Equatable {
    @usableFromInline
    static func isEqual(_ lhs: Any, _ rhs: Any) -> Bool {
        lhs as? WrappedValue == rhs as? WrappedValue
    }
}
