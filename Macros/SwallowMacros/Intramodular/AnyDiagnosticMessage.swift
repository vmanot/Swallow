//
// Copyright (c) Vatsal Manot
//

import SwiftDiagnostics

public struct AnyDiagnosticMessage: DiagnosticMessage, Error, FixItMessage, ExpressibleByStringLiteral {
    public let message: String
    public let severity: DiagnosticSeverity
    
    public let file: StaticString?
    
    public var diagnosticID: MessageID {
        .init(domain: module.domain, id: message)
    }
    
    public var fixItID: MessageID {
        diagnosticID
    }
    
    public init(
        message: String,
        severity: DiagnosticSeverity = .error,
        file: StaticString? = #fileID
    ) {
        self.message = message
        self.severity = severity
        self.file = file
    }
    
    public init(stringLiteral value: String) {
        self.init(message: value, severity: .error, file: nil)
    }
}
