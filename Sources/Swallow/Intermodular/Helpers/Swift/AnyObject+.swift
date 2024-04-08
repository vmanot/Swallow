//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swift

@_transparent
public func isClass(
    _ cls: AnyClass,
    descendantOf otherCls: AnyClass
) -> Bool {
    guard cls != otherCls else {
        return false
    }
    
    guard class_getSuperclass(otherCls) != cls else {
        return false
    }
    
    var cls: AnyClass = cls
    
    while let superclass = class_getSuperclass(cls) {
        if superclass == otherCls {
            return true
        }
        
        cls = superclass
    }
    
    return false
}

@_transparent
public func isType(
    _ type: Any.Type,
    descendantOf otherType: Any.Type
) -> Bool {
    guard let cls = type as? AnyClass, let otherCls = otherType as? AnyClass else {
        return false
    }
    
    return isClass(cls, descendantOf: otherCls)
}

@_silgen_name("swift_isClassType")
public func swift_isClassType(
    _: Any.Type
) -> Bool

@_transparent
public func isAnyObject<T>(_ x: T) -> Bool {
    return swift_isClassType(type(of: x))
}

@_transparent
public func isAnyObject<T>(_ x: T?) -> Bool {
    return swift_isClassType(T.self)
}
