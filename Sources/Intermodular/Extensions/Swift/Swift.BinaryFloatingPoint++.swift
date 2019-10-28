//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swift

extension BinaryFloatingPoint {
    public var isInteger: Bool {
        return floor(self) == self
    }
}
