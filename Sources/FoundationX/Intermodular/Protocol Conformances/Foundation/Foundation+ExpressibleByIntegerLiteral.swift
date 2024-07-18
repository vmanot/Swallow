//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension Foundation.IndexPath: Swift.ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(index: value)
    }
}

extension Foundation.IndexSet: Swift.ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(integer: value)
    }
}

extension Foundation.NSRange: Swift.ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(value)
    }
}
