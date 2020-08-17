//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _opaque_MutableRawRepresentable: _opaque_RawRepresentable {
    mutating func _opaque_MutableWrapper_set(rawValue: Any) -> Void?
}
