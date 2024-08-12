//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

extension ExprSyntaxProtocol {
    public var isElementsEmpty: Bool {
        if let syntax = self as? ExprSyntax {
            return syntax.isElementsEmpty
        } else if let syntax = self as? ArrayExprSyntax {
            return syntax._isElementsEmpty
        } else if let syntax = self as? DictionaryExprSyntax {
            return syntax._isElementsEmpty
        } else {
            return false
        }
    }
}

// MARK: - Internal

extension ExprSyntax {
    fileprivate var _isElementsEmpty: Bool {
        if let array = self.as(ArrayExprSyntax.self) {
            return array.isElementsEmpty
        } else if let dictionary = self.as(DictionaryExprSyntax.self) {
            return dictionary.isElementsEmpty
        }
        
        return false
    }
}

extension ArrayExprSyntax {
    fileprivate var _isElementsEmpty: Bool {
        if elements.isEmpty {
            return true
        }
        
        return elements
            .lazy
            .map(\.expression)
            .filter { (expr: ExprSyntax) in
                if let arrayExpr = expr.as(ArrayExprSyntax.self) {
                    return !arrayExpr.isElementsEmpty
                } else {
                    return true
                }
            }
            .isEmpty
    }
}

extension DictionaryExprSyntax {
    fileprivate var _isElementsEmpty: Bool {
        switch content {
            case .colon:
                return true
            case .elements:
                return false
            @unknown default:
                fatalError()
        }
    }
}
