//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public struct POSIXProcessIdentifier: Wrapper {
    public typealias Value = pid_t

    public let value: Value

    public init(_ value: Value) {
        self.value = value
    }

    public static var current: POSIXProcessIdentifier {
        return .init(getpid())
    }
}
