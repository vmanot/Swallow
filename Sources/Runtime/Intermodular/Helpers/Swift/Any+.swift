//
// Copyright (c) Vatsal Manot
//

import Swallow

protocol _ExtendedMetatype {
    
}

func _extendMetatype(_ type: Any.Type) -> _ExtendedMetatype.Type {
    struct _Extended: _ExtendedMetatype {
        
    }
    
    var result: _ExtendedMetatype.Type = _Extended.self
    
    UnsafeMutablePointer<Any.Type>.to(assumingLayoutCompatible: &result).pointee = type
    
    return result
}

extension _ExtendedMetatype {
    private static var t0: Self.Type {
        Self.self
    }
    
    static func Array_Self() -> Any.Type {
        Array<Self>.self
    }
    
    static func UnsafePointer_Self() -> Any.Type {
        UnsafePointer<Self>.self
    }
    
    static func UnsafeMutablePointer_Self() -> Any.Type {
        UnsafeMutablePointer<Self>.self
    }
    
    static func concatenateAsFunctionType<T>(withReturnType _: T.Type) -> _ExtendedMetatype.Type {
        _extendMetatype(((T) -> Self).self)
    }
    
    static func concatenateAsFunctionType(
        withUnknownReturnType t1: _ExtendedMetatype.Type
    ) -> _ExtendedMetatype.Type {
        t1.concatenateAsFunctionType(withReturnType: t0)
    }
    
    static func concatenate<T>(with _: T.Type) -> _ExtendedMetatype.Type {
        _extendMetatype((T, Self).self)
    }
    
    static func concatenate(withUnknown t1: _ExtendedMetatype.Type) -> _ExtendedMetatype.Type {
        t1.concatenate(with: t0)
    }
    
    static func concatenate<T, U>(with _: T.Type, _: U.Type) -> _ExtendedMetatype.Type {
        _extendMetatype((U, T, Self).self)
    }
    
    static func concatenate<T>(with t1: T.Type, unknown t2: _ExtendedMetatype.Type) -> _ExtendedMetatype.Type {
        t2.concatenate(with: t0, t1)
    }
    
    static func concatenate(withUnknown t1: _ExtendedMetatype.Type, _ t2: _ExtendedMetatype.Type) -> _ExtendedMetatype.Type {
        t1.concatenate(with: t0, unknown: t2)
    }
    
    static func concatenate<T, U, V>(with t1: T.Type, _ t2: U.Type, _ t3: V.Type) -> _ExtendedMetatype.Type {
        _extendMetatype((V, U, T, Self).self)
    }
    
    static func concatenate<T, U>(with t1: T.Type, _ t2: U.Type, unknown t3: _ExtendedMetatype.Type) -> _ExtendedMetatype.Type {
        t3.concatenate(with: t0, t1, t2)
    }
    
    static func concatenate<T>(with t1: T.Type, unknown t2: _ExtendedMetatype.Type, _ t3: _ExtendedMetatype.Type) -> _ExtendedMetatype.Type {
        t2.concatenate(with: t0, t1, unknown: t3)
    }
    
    static func concatenate(withUnknown t1: _ExtendedMetatype.Type, _ t2: _ExtendedMetatype.Type, _ t3: _ExtendedMetatype.Type) -> _ExtendedMetatype.Type {
        t1.concatenate(with: t0, unknown: t2, t3)
    }
    
    static func concatenate<T, U, V, W>(with t1: T.Type, _ t2: U.Type, _ t3: V.Type, _ t4: W.Type) -> _ExtendedMetatype.Type {
        _extendMetatype((W, V, U, T, Self).self)
    }
    
    static func concatenate<T, U, V>(with t1: T.Type, _ t2: U.Type, _ t3: V.Type, unknown t4: _ExtendedMetatype.Type) -> _ExtendedMetatype.Type {
        t4.concatenate(with: t0, t1, t2, t3)
    }
    
    static func concatenate<T, U>(with t1: T.Type, _ t2: U.Type, unknown t3: _ExtendedMetatype.Type, _ t4: _ExtendedMetatype.Type) -> _ExtendedMetatype.Type {
        t3.concatenate(with: t0, t1, t2, unknown: t4)
    }
    
    static func concatenate<T>(with t1: T.Type, unknown t2: _ExtendedMetatype.Type, _ t3: _ExtendedMetatype.Type, _ t4: _ExtendedMetatype.Type) -> _ExtendedMetatype.Type {
        t2.concatenate(with: t0, t1, unknown: t3, t4)
    }
    
    static func concatenate(withUnknown t1: _ExtendedMetatype.Type, _ t2: _ExtendedMetatype.Type, _ t3: _ExtendedMetatype.Type, _ t4: _ExtendedMetatype.Type) -> _ExtendedMetatype.Type {
        t1.concatenate(with: t0, unknown: t2, t3, t4)
    }
    
    static func concatenate<T, U, V, W, X>(with t1: T.Type, _ t2: U.Type, _ t3: V.Type, _ t4: W.Type, _ t5: X.Type) -> _ExtendedMetatype.Type {
        _extendMetatype((X, W, V, U, T, Self).self)
    }
    
    static func concatenate<T, U, V, W>(with t1: T.Type, _ t2: U.Type, _ t3: V.Type, _ t4: W.Type, unknown t5: _ExtendedMetatype.Type) -> _ExtendedMetatype.Type {
        t5.concatenate(with: t0, t1, t2, t3, t4)
    }
    
    static func concatenate<T, U, V>(with t1: T.Type, _ t2: U.Type, _ t3: V.Type, unknown t4: _ExtendedMetatype.Type, _ t5: _ExtendedMetatype.Type) -> _ExtendedMetatype.Type {
        t4.concatenate(with: t0, t1, t2, t3, unknown: t5)
    }
    
    static func concatenate<T, U>(with t1: T.Type, _ t2: U.Type, unknown t3: _ExtendedMetatype.Type, _ t4: _ExtendedMetatype.Type, _ t5: _ExtendedMetatype.Type) -> _ExtendedMetatype.Type {
        t3.concatenate(with: t0, t1, t2, unknown: t4, t5)
    }
    
    static func concatenate<T>(with t1: T.Type, unknown t2: _ExtendedMetatype.Type, _ t3: _ExtendedMetatype.Type, _ t4: _ExtendedMetatype.Type, _ t5: _ExtendedMetatype.Type) -> _ExtendedMetatype.Type {
        t2.concatenate(with: t0, t1, unknown: t3, t4, t5)
    }
    
    static func concatenate(withUnknown t1: _ExtendedMetatype.Type, _ t2: _ExtendedMetatype.Type, _ t3: _ExtendedMetatype.Type, _ t4: _ExtendedMetatype.Type, _ t5: _ExtendedMetatype.Type) -> _ExtendedMetatype.Type {
        t1.concatenate(with: t0, unknown: t2, t3, t4, t5)
    }
}

public func _concatenateAsFunctionType(_ t1: Any.Type, returnType t2: Any.Type) -> Any.Type {
    _extendMetatype(t1).concatenateAsFunctionType(withUnknownReturnType: _extendMetatype(t2))
}

public func _concatenateAsFunctionType(_ t1: TypeMetadata, returnType t2: TypeMetadata) -> TypeMetadata.Function {
    TypeMetadata.Function(_concatenateAsFunctionType(t1.base, returnType: t2.base))!
}

public func _concatenate(_ t1: Any.Type, _ t2: Any.Type) -> Any.Type {
    _extendMetatype(t1).concatenate(withUnknown: _extendMetatype(t2))
}

public func _concatenate(_ t1: TypeMetadata, _ t2: TypeMetadata) -> TypeMetadata {
    .init(_extendMetatype(t1.base).concatenate(withUnknown: _extendMetatype(t2.base)))
}

public func _concatenate(_ t1: Any.Type, _ t2: Any.Type, _ t3: Any.Type) -> Any.Type {
    _extendMetatype(t1).concatenate(withUnknown: _extendMetatype(t2), _extendMetatype(t3))
}

public func _concatenate(_ t1: TypeMetadata, _ t2: TypeMetadata, _ t3: TypeMetadata) -> TypeMetadata {
    .init(_extendMetatype(t1.base).concatenate(withUnknown: _extendMetatype(t2.base), _extendMetatype(t3.base)))
}

public func _concatenate(_ t1: Any.Type, _ t2: Any.Type, _ t3: Any.Type, _ t4: Any.Type) -> Any.Type {
    _extendMetatype(t1).concatenate(withUnknown: _extendMetatype(t2), _extendMetatype(t3), _extendMetatype(t4))
}

public func _concatenate(_ t1: TypeMetadata, _ t2: TypeMetadata, _ t3: TypeMetadata, _ t4: TypeMetadata) -> TypeMetadata {
    .init(_extendMetatype(t1.base).concatenate(withUnknown: _extendMetatype(t2.base), _extendMetatype(t3.base), _extendMetatype(t4.base)))
}

public func _concatenate(_ t1: Any.Type, _ t2: Any.Type, _ t3: Any.Type, _ t4: Any.Type, _ t5: Any.Type) -> Any.Type {
    _extendMetatype(t1).concatenate(withUnknown: _extendMetatype(t2), _extendMetatype(t3), _extendMetatype(t4), _extendMetatype(t5))
}

public func _concatenate(_ t1: TypeMetadata, _ t2: TypeMetadata, _ t3: TypeMetadata, _ t4: TypeMetadata, _ t5: TypeMetadata) -> TypeMetadata {
    .init(_extendMetatype(t1.base).concatenate(withUnknown: _extendMetatype(t2.base), _extendMetatype(t3.base), _extendMetatype(t4.base), _extendMetatype(t5.base)))
}

public func _concatenate(_ t1: Any.Type, _ t2: Any.Type, _ t3: Any.Type, _ t4: Any.Type, _ t5: Any.Type, _ t6: Any.Type) -> Any.Type {
    _extendMetatype(t1).concatenate(withUnknown: _extendMetatype(t2), _extendMetatype(t3), _extendMetatype(t4), _extendMetatype(t5), _extendMetatype(t6))
}

public func _concatenate(_ t1: TypeMetadata, _ t2: TypeMetadata, _ t3: TypeMetadata, _ t4: TypeMetadata, _ t5: TypeMetadata, _ t6: TypeMetadata) -> TypeMetadata {
    .init(_extendMetatype(t1.base).concatenate(withUnknown: _extendMetatype(t2.base), _extendMetatype(t3.base), _extendMetatype(t4.base), _extendMetatype(t5.base), _extendMetatype(t6.base)))
}
