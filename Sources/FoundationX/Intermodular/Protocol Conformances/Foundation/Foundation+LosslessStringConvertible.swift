//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension CharacterSet: LosslessStringConvertible {
    public init(_ description: String) {
        self.init(charactersIn: description)
    }
}

extension Decimal: LosslessStringConvertible {
    public init?(_ description: String) {
        self.init(string: description, locale: nil)
    }
}

extension NSString {
    public convenience init(_ description: String) {
        self.init(format: description as NSString)
    }
}
