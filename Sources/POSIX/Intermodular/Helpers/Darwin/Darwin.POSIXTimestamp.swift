//
// Copyright (c) Vatsal Manot
//

import Darwin
import Foundation
import Swallow

public struct POSIXTimestamp: Hashable {
    public typealias Value = timeval

    public let value: Value

    public init(_ value: Value) {
        self.value = value
    }

    public static func current() -> POSIXTimestamp {
        var value = timeval(tv_sec: 0, tv_usec: 0)
        gettimeofday(&value, nil)
        return .init(value)
    }
}
