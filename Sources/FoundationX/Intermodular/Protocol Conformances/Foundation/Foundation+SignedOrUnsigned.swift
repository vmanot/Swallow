//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension NSNumber {
    @objc public dynamic static var canBeSignMinus: Bool {
        return true
    }
    
    @objc public dynamic var isSignMinus: Bool {
        return .orderedDescending == NSDecimalNumber.zero.compare(self)
    }
}
