//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftDiagnostics
import SwiftSyntax

public enum CustomMacroExpansionError: Error {
    case message(AnyDiagnosticMessage)
            
    public init(file: String = #fileID) {
        self = .message(AnyDiagnosticMessage(stringLiteral: "An unknown error occurred in \(file)."))
    }
}

// MARK: - Initializers

extension CustomMacroExpansionError {
    public static func diagnostic(
        node: Syntax,
        position: AbsolutePosition? = nil,
        message: AnyDiagnosticMessage,
        highlights: [Syntax]? = nil,
        notes: [Note] = [],
        fixIts: [FixIt] = []
    ) -> Diagnostic {
        Diagnostic(
            node: node,
            message: message
        )
    }
}

// MARK: - Conformances

extension CustomMacroExpansionError: CustomStringConvertible {
    public var description: String {
        switch self {
            case .message(let message):
                return message.message
        }
    }
}
