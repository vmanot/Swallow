//
// Copyright (c) Vatsal Manot
//

#if canImport(CoreGraphics)

import CoreGraphics
import Foundation
import Swift

extension CGFloat: Continuous, Signed, Number {
    public init(uncheckedOpaqueValue value: _opaque_Number) {
        self = value.toCGFloat()
    }

    @inlinable
    public init<N: _opaque_Number>(unchecked value: N) {
        self = value.toCGFloat()
    }

    @inlinable
    public func toNSNumber() -> NSNumber {
        return self as NSNumber
    }
}

#endif
