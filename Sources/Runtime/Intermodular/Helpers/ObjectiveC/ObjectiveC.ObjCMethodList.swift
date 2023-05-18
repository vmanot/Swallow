//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

public struct ObjCMethodList: Wrapper {
    public typealias Value = UnsafeRawPointer
    
    public let value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
}
