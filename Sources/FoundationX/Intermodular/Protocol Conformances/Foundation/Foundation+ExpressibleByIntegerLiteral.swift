//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension Foundation.IndexPath: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(index: value)
    }
}

extension Foundation.IndexSet: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(integer: value)
    }
}

extension Foundation.NSRange: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(value)
    }
}
