//
// Copyright (c) Vatsal Manot
//

import SwiftDiagnostics
import Swallow

public struct AnyDiagnosticMessage: DiagnosticMessage, Error, FixItMessage, ExpressibleByStringLiteral {
    public let message: String
    public let severity: DiagnosticSeverity
    
    public let file: StaticString?
    
    public var diagnosticID: MessageID {
        .init(domain: "com.vmanot.SwallowMacros", id: message)
    }
    
    public var fixItID: MessageID {
        diagnosticID
    }
    
    public init(
        message: String = "An unknown error occurred in \(#fileID).", 
        severity: DiagnosticSeverity = .error,
        file: StaticString? = #fileID
    ) {
        self.message = message
        self.severity = severity
        self.file = file
    }
    
    public init(
        _ error: Never.Reason,
        file: StaticString? = #file
    ) {
        self.init(
            message: String(describing: error),
            severity: .error,
            file: file
        )
    }
    
    public init(stringLiteral value: String) {
        self.init(message: value, severity: .error, file: nil)
    }
}
