//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

extension POSIXErrorCode: Swift.ExpressibleByIntegerLiteral {
    public init(integerLiteral value: RawValue) {
        self = type(of: self).init(rawValue: value)!
    }
}
