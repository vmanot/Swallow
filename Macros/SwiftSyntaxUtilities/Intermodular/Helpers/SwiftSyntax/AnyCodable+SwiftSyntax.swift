//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftParser
import SwiftSyntax

extension LabeledExprListSyntax  {
    /// Decodes this macro argument list through its supported `AnyCodable` representation.
    public func decode<T: Decodable>(
        _ type: T.Type
    ) throws -> T {
        let data = try AnyCodable(from: self)

        return try _decodeMacroArguments(type, from: data)
    }
}

extension AttributeSyntax {
    /// Decodes this attribute's ordinary argument list, treating no parentheses as empty.
    public func decode<T: Decodable>(
        _ type: T.Type
    ) throws -> T {
        let data = try AnyCodable(from: ordinaryArgumentListOrEmpty())

        return try _decodeMacroArguments(type, from: data)
    }
}

extension AnyCodable {
    fileprivate func _solePositionalMacroArgument() throws -> AnyCodable? {
        guard let dictionary = _dictionaryValue else {
            throw CustomStringError(description: "Expected a dictionary-backed macro argument list.")
        }

        guard !dictionary.isEmpty else {
            return nil
        }

        guard dictionary.count == 1,
              let (key, value) = dictionary.first,
              key.intValue == 0 else {
            throw CustomStringError(description: "Expected exactly one positional macro argument.")
        }

        return value
    }
}

private func _decodeMacroArguments<T: Decodable>(
    _ type: T.Type,
    from data: AnyCodable
) throws -> T {
    do {
        return try T(from: data)
    } catch let primaryError {
        do {
            if let value = try data._solePositionalMacroArgument() {
                return try T(from: value)
            }

            return try _attemptToDecodeOptionalNone(from: type)
        } catch {
            throw primaryError
        }
    }
}

extension AnyCodable {
    public init(from exprList: LabeledExprListSyntax) throws {
        self = .dictionary(
            try Dictionary(
                try exprList.enumerated().map { offset, syntax in
                    let key: AnyCodingKey

                    if let text = syntax.labelName {
                        key = AnyCodingKey(stringLiteral: text)
                    } else {
                        key = AnyCodingKey(integerLiteral: offset)
                    }
                    
                    let value = try syntax.expression.macroArgumentCodableRepresentation()
                    
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
    /// Builds the intermediate value supported by the Codable macro bridge.
    ///
    /// Supported forms are Boolean, `nil`, non-interpolated string literals,
    /// and explicitly qualified declaration references such as `Mode.strict`.
    public func macroArgumentCodableRepresentation() throws -> AnyCodable? {
        if let expression = self.as(BooleanLiteralExprSyntax.self) {
            switch expression.literal.tokenKind {
                case .keyword(.true):
                    return .bool(true)
                case .keyword(.false):
                    return .bool(false)
                default:
                    throw unsupportedMacroArgumentDiagnostic
            }
        }
        
        if self.is(NilLiteralExprSyntax.self) {
            return nil
        }
        
        if let expression = self.as(StringLiteralExprSyntax.self) {
            guard let value = expression.representedLiteralValue else {
                throw unsupportedMacroArgumentDiagnostic
            }

            return .string(value)
        }
        
        if let components = directDeclReferenceNameComponents {
            return .string(components.joined(separator: "."))
        }

        throw unsupportedMacroArgumentDiagnostic
    }

    private var unsupportedMacroArgumentDiagnostic: MacroExpansionDiagnosticMessage {
        MacroExpansionDiagnosticMessage(
            message: "Unsupported macro argument expression '\(trimmedDescription)'.",
            domain: "com.vmanot.SwiftSyntaxUtilities",
            id: "unsupportedMacroArgumentExpression"
        )
    }
}
