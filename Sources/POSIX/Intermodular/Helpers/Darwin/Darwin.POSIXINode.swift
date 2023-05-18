//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public struct POSIXINode: Wrapper {
    public typealias Value = ino_t
    
    public let value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
}
