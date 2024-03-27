//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftSyntax

extension ExprSyntax {
    var isElementsEmpty: Bool {
        if let array = self.as(ArrayExprSyntax.self) {
            return array.isElementsEmpty
        } else if let dictionary = self.as(DictionaryExprSyntax.self) {
            return dictionary.isElementsEmpty
        }
        return false
    }
}

extension ArrayExprSyntax {
    var isElementsEmpty: Bool {
        if elements.isEmpty { return true }
        return elements
            .lazy
            .map(\.expression)
            .filter { exp in
                if let arrayExp = exp.as(ArrayExprSyntax.self) {
                    return !arrayExp.isElementsEmpty
                } else {
                    return true
                }
            }.isEmpty
    }
}

extension DictionaryExprSyntax {
    var isElementsEmpty: Bool {
        switch content {
        case .colon: return true
        case .elements: return false
        }
    }
}
