//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol opaque_MutableRawRepresentable: opaque_RawRepresentable {
    mutating func opaque_MutableWrapper_set(rawValue: Any) -> Void?
}
