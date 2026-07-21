//
// Copyright (c) Vatsal Manot
//

import SwiftDiagnostics
import Swallow

public struct MacroExpansionDiagnosticMessage: DiagnosticMessage, Error, FixItMessage {
    public let message: String
    public let severity: DiagnosticSeverity
    public let diagnosticID: MessageID

    public var fixItID: MessageID {
        diagnosticID
    }

    public init(
        message: String,
        severity: DiagnosticSeverity = .error,
        diagnosticID: MessageID = .init(
            domain: "com.vmanot.SwiftSyntaxUtilities",
            id: "unspecifiedDiagnostic"
        )
    ) {
        self.message = message
        self.severity = severity
        self.diagnosticID = diagnosticID
    }

    public init(
        message: String,
        severity: DiagnosticSeverity = .error,
        domain: String,
        id: String
    ) {
        self.init(
            message: message,
            severity: severity,
            diagnosticID: .init(domain: domain, id: id)
        )
    }
}

extension MacroExpansionDiagnosticMessage {
    public init(
        _ error: Never.Reason
    ) {
        self.init(
            message: String(describing: error),
            severity: .error
        )
    }
}

// MARK: - Conformances

extension MacroExpansionDiagnosticMessage: ExpressibleByStringLiteral {
    public init(
        stringLiteral value: String
    ) {
        self.init(message: value, severity: .error)
    }
}
