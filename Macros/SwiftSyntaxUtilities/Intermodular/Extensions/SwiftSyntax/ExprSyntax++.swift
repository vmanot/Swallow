//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftSyntax

extension ExprSyntax {
    public mutating func prepend(_ other: ExprSyntax, separator: String) {
        self = prepending(other, separator: separator)
    }
    
    public func prepending(_ other: ExprSyntax, separator: String) -> ExprSyntax {
        if self.description == "" {
            return other
        } else {
            return "\(other)\(raw: separator)\(self)"
        }
    }
    
}
extension ExprSyntax {
    public var isNil: Bool {
        kind == .nilLiteralExpr
    }
}

extension Sequence where Element == ExprSyntax {
    public func allSatisfy(_ kind: SyntaxKind) -> Bool {
        allSatisfy({ $0.kind == kind })
    }
}
