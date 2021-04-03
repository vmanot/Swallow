//
// Copyright (c) Vatsal Manot
//

import Swift

public typealias RawRepresentable2 = _opaque_RawRepresentable & RawRepresentable

public protocol _opaque_RawRepresentable: AnyProtocol {
    var _opaque_RawRepresentable_rawValue: Any { get }
    
    static func _opaque_RawRepresentable_init(rawValue: Any) -> _opaque_RawRepresentable?
}

extension RawRepresentable where Self: _opaque_RawRepresentable {
    public var _opaque_RawRepresentable_rawValue: Any {
        return rawValue
    }
    
    public static func _opaque_RawRepresentable_init(rawValue: Any) -> _opaque_RawRepresentable? {
        return (-?>rawValue).flatMap({ self.init(rawValue: $0) })
    }
}
