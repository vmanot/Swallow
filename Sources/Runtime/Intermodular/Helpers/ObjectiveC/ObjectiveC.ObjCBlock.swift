//
// Copyright (c) Vatsal Manot
//

import Foundation
import ObjectiveC
import Swallow

public struct ObjCBlock: CustomDebugStringConvertible, Wrapper {
    public typealias Value = ObjCObject
    
    public let value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
}
