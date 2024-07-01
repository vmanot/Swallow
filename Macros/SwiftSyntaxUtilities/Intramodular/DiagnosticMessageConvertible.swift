//
// Copyright (c) Vatsal Manot
//

import SwiftDiagnostics

public protocol DiagnosticMessageConvertible: DiagnosticMessage {
    func __conversion() throws -> SwiftDiagnostics.DiagnosticMessage
}

extension DiagnosticMessageConvertible {
    public var message: String {
        try! __conversion().message
    }
    
    public var diagnosticID: MessageID {
        try! __conversion().diagnosticID
    }
    
    public var severity: DiagnosticSeverity {
        try! __conversion().severity
    }
}
