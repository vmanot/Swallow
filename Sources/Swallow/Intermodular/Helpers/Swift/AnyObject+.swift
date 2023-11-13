//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swift

public protocol _FinalClassAnyObject {
    
}

extension _FinalClassAnyObject {
    public typealias _Self = _FinalClassAnyObject
}

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

public func isAnyObject<T>(_ x: T) -> Bool {
    return swift_isClassType(type(of: x))
}

public func isAnyObject<T>(_ x: T?) -> Bool {
    return swift_isClassType(T.self)
}
