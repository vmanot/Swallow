//
// Copyright (c) Vatsal Manot
//

#if canImport(CoreGraphics)

import CoreGraphics
import Swift

extension CGFloat: LosslessStringConvertible {
    @inlinable
    public init?(_ text: String) {
        guard let value = CGFloat.NativeType(text) else {
            return nil
        }

        self.init(value)
    }
}

#endif
