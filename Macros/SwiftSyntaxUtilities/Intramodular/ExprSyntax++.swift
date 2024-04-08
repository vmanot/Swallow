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

extension ExprSyntax {
    func _decodeLiteralValueOrAsString() throws -> AnyCodable? {
        do {
            return try decodeLiteral()
        } catch(let _error) {
            if let decl = self.as(MemberAccessExprSyntax.self), let name = decl._fullName {
                return .string(name)
            } else {
                throw _error
            }
        }
    }
    
    public func decodeLiteral() throws -> AnyCodable? {
        // TODO: Improve this.
        enum _Error: Swift.Error {
            case failure
        }
        
        if let expression = self.as(BooleanLiteralExprSyntax.self) {
            switch expression.literal.tokenKind {
                case .keyword(.true):
                    return .bool(true)
                case .keyword(.false):
                    return .bool(false)
                default:
                    throw _Error.failure
            }
        }
        
        if let _ = self.as(DictionaryExprSyntax.self) {
            fatalError()
        }
        
        if let expression = self.as(NilLiteralExprSyntax.self) {
            _ = expression
            
            return nil
        }
        
        if let expression = self.as(StringLiteralExprSyntax.self) {
            let segment = try expression.segments
                .toCollectionOfOne()
                .value
                .as(StringSegmentSyntax.self)
                .unwrap()
            
            switch segment.content.tokenKind {
                case .stringSegment(let text):
                    return .string(text)
                default:
                    throw _Error.failure
            }
        }
        
        if let expression = self.as(MemberAccessExprSyntax.self) {
            return .string(try expression._fullName.unwrap())
         }
        
        throw CustomStringError(description: "Unsupported")
    }
}

extension MemberAccessExprSyntax {
    // TODO: Rename
    fileprivate var _fullName: String? {
        guard let base else {
            return nil
        }
        
        if let base = base.as(DeclReferenceExprSyntax.self) {
            return base.baseName.text
        }
        
        if
            let base = base.as(MemberAccessExprSyntax.self),
            let _base = base.base?.as(DeclReferenceExprSyntax.self)
        {
            return _base.baseName.text + "." + base.declName.baseName.text
        }
        
        return nil
    }
}
