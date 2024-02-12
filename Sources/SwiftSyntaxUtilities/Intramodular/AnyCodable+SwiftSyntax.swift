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
    public func _toCollectionOfOne() throws -> AnyCodable? {
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
