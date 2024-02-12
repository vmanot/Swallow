//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftSyntax

/// https://github.com/beccadax/swift-macro-examples
extension LabeledExprListSyntax {
    public func first(
        labeled name: String
    ) -> Element? {
        return first { element in
            if let label = element.label, label.text == name {
                return true
            }
            
            return false
        }
    }
    
    public func last(
        labeled name: String
    ) -> Element? {
        return last { element in
            if let label = element.label, label.text == name {
                return true
            }
            
            return false
        }
    }
}
