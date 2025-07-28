//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension NSRegularExpression.Options: Swift.ExpressibleByExtendedGraphemeClusterLiteral, Swift.ExpressibleByStringLiteral, Swift.ExpressibleByUnicodeScalarLiteral {
    public init(stringLiteral: String) {
        self.init(modeModifier: Character(stringLiteral))!
    }
}
