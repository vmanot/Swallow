//
// Copyright (c) Vatsal Manot
//

import Swift

public typealias RawRepresentable2 = opaque_RawRepresentable & RawRepresentable

public protocol opaque_RawRepresentable: AnyProtocol {
    var opaque_RawRepresentable_rawValue: Any { get }
    
    static func opaque_RawRepresentable_init(rawValue: Any) -> opaque_RawRepresentable?
}

extension opaque_RawRepresentable where Self: RawRepresentable {
    public var opaque_RawRepresentable_rawValue: Any {
        return rawValue
    }
    
    public static func opaque_RawRepresentable_init(rawValue: Any) -> opaque_RawRepresentable? {
        return (-?>rawValue).flatMap({ self.init(rawValue: $0) })
    }
}
