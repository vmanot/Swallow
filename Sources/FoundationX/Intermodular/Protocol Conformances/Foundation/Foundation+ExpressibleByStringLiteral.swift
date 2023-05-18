//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension NSRegularExpression.Options: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        self.init(modeModifier: Character(stringLiteral))!
    }
}
