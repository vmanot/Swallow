//
// Copyright (c) Vatsal Manot
//

import Swift

@frozen
public struct _TypeHashingAnyHashable: _UnwrappableHashableTypeEraser {
    @usableFromInline
    let _base: AnyHashable
    
    @_transparent
    public var base: any Hashable {
        _base.base as! (any Hashable)
    }
    
    @_transparent
    public init<H: Hashable>(_ base: H) {
        self._base = AnyHashable(base)
    }
    
    @_transparent
    public init(_erasing base: any Hashable) {
        self = base._eraseToTypeHashingAnyHashable()
    }
    
    @_transparent
    public func _unwrapBase() -> _UnwrappedBaseType {
        base
    }
}

// MARK: - Conformances

extension _TypeHashingAnyHashable: Hashable {
    @_transparent
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(type(of: _base.base)))
        hasher.combine(_base)
    }
    
    @_transparent
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard type(of: lhs._base.base) == type(of: rhs._base.base) else {
            return false
        }
        
        return rhs._base == lhs._base
    }
}

// MARK: - Supplementary

extension Hashable {
    @_transparent
    public func _eraseToTypeHashingAnyHashable() -> _TypeHashingAnyHashable {
        _TypeHashingAnyHashable(self)
    }
}
