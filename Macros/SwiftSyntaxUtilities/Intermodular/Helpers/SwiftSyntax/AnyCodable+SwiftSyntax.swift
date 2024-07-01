//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftSyntax

extension LabeledExprListSyntax  {
    public func decode<T: Decodable>(
        _ type: T.Type
    ) throws -> T {
        let data = try AnyCodable(from: self)
        
        do {
            return try T(from: data)
        } catch {
            if let value = try data._toCollectionOfOne() {
                return try T(from: value)
            } else {
                return try _attemptToDecodeOptionalNone(from: type)
            }
        }
    }
}

extension AttributeSyntax {
    public func decode<T: Decodable>(
        _ type: T.Type
    ) throws -> T {
        let data = try AnyCodable(from: self.labeledArguments.unwrap())
        
        do {
            return try T(from: data)
        } catch(let error0) {
            do {
                if let value = try data._toCollectionOfOne() {
                    return try T(from: value)
                } else {
                    return try _attemptToDecodeOptionalNone(from: type)
                }
            } catch {
                throw error0
            }
        }
    }
}

extension AnyCodable {
    fileprivate func _toCollectionOfOne() throws -> AnyCodable? {
        if let array = self._arrayValue, array.count == 1, let value = array.first {
            return value
        } else if let dictionary = self._dictionaryValue, dictionary.count <= 1 {
            if dictionary.isEmpty {
                return nil
            }
            
            let (key, value) = dictionary.first!
            
            guard key.intValue == 0 else {
                throw CustomStringError(description: "got \(key)")
            }
            
            return value
        }
        
        throw CustomStringError(description: "Could not decompose \(self)")
    }
}

extension AnyCodable {
    public init(from exprList: LabeledExprListSyntax) throws {
        self = .dictionary(
            try Dictionary(
                try exprList.enumerated().map { offset, syntax in
                    let key: AnyCodingKey

                    if let text =  syntax.labelText {
                        key = AnyCodingKey(stringLiteral: text)
                    } else {
                        key = AnyCodingKey(integerLiteral: offset)
                    }
                    
                    let value = try syntax.expression._decodeLiteralValueOrAsString()
                    
                    return (key, value)
                },
                uniquingKeysWith: { lhs, rhs in
                    throw CustomStringError(stringLiteral: "Duplicate key: \(String(describing: lhs))")
                }
            )
            .compactMapValues({ $0 })
        )
    }
}

extension ExprSyntax {
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
    
    fileprivate func _decodeLiteralValueOrAsString() throws -> AnyCodable? {
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
