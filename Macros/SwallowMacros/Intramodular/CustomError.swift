//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum CustomError: CustomStringConvertible, Error {
    struct _CustomErrorMessage: DiagnosticMessage, Error {
        let message: String
        let diagnosticID: MessageID
        let severity: DiagnosticSeverity
    }
    
    case message(String)
    
    public var description: String {
        switch self {
            case .message(let text): 
                return text
        }
    }

    static func diagnostic(
        node: Syntax,
        position: AbsolutePosition? = nil,
        message: _CustomErrorMessage,
        highlights: [Syntax]? = nil,
        notes: [Note] = [],
        fixIts: [FixIt] = []
    ) -> Diagnostic {
        Diagnostic(
            node: node,
            message: message
        )
    }
        
    init(file: String = #fileID) {
        self = CustomError.message("An unknown error occurred in \(file).")
    }
}

extension CustomError._CustomErrorMessage: FixItMessage {
    var fixItID: MessageID {
        diagnosticID
    }
}
