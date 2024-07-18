//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

extension Selector: Swallow.StringConvertible {
    public var stringValue: String {
        return value
    }
    
    public init(stringValue: String) {
        self.init(stringValue)
    }
}
