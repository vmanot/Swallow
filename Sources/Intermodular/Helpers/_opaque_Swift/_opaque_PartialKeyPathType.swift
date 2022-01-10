//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public protocol _opaque_PartialKeyPathType {
    static var _opaque_RootType: Any.Type { get }
}

public protocol _opaque_KeyPathType: _opaque_PartialKeyPathType {
    static var _opaque_ValueType: Any.Type { get }
}

// MARK: - Implementation -

extension PartialKeyPath: _opaque_PartialKeyPathType {
    public static var _opaque_RootType: Any.Type {
        Root.self
    }
}

extension KeyPath: _opaque_KeyPathType {
    public static var _opaque_ValueType: Any.Type {
        Value.self
    }
}
