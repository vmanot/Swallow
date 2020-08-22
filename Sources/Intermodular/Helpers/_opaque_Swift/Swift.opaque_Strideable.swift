//
// Copyright (c) Vatsal Manot
//

import Swift

public typealias Strideable2 = _opaque_Strideable & Strideable

public protocol _opaque_Strideable: _opaque_Comparable {
    static var _opaque_Strideable_Stride: Any.Type { get }
    
    func _opaque_Strideable_distance(to _: Any) -> Any?
    func _opaque_Strideable_advanced(by _: Any) -> Self?
}

extension _opaque_Strideable where Self: Strideable {
    public static var _opaque_Strideable_Stride: Any.Type {
        return Stride.self
    }
    
    public func _opaque_Strideable_distance(to other: Any) -> Any? {
        return (-?>other).map(distance)
    }

    public func _opaque_Strideable_advanced(by distance: Any) -> Self? {
        return (-?>distance).map(advanced)
    }
}
