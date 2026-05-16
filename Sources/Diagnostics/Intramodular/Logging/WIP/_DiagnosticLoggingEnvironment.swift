//
// Copyright (c) Vatsal Manot
//

import Swallow

public struct _DiagnosticLoggingEnvironment: Sendable {
    public var textOutput: PassthroughLogger.ResolvedTextOutput?
    
    public init(
        textOutput: PassthroughLogger.ResolvedTextOutput? = nil
    ) {
        self.textOutput = textOutput
    }
}

public enum _GlobalDiagnosticLoggingEnvironment {
    public static var isBootstrapped: Bool {
        _DiagnosticLoggingValues.environment.isValueFixed
    }
    
    public static func bootstrap(
        _ environment: _DiagnosticLoggingEnvironment
    ) {
        _DiagnosticLoggingValues.environment.fixValue(environment)
    }
}

extension _DiagnosticLoggingEnvironment {
    public static func withEnvironment<R>(
        _ environment: Self,
        operation: () throws -> R
    ) rethrows -> R {
        try _DiagnosticLoggingValues.environment.withValue(environment) {
            try operation()
        }
    }
    
    public static func withEnvironment<R>(
        _ environment: Self,
        operation: () async throws -> R
    ) async rethrows -> R {
        try await _DiagnosticLoggingValues.environment.withValue(environment) {
            try await operation()
        }
    }
}

enum _DiagnosticLoggingValues {
    // Static wrapper vars trip Swift 6 mutable-global checking; the wrapper object is the state boundary.
    static let environment = _GlobalSetOnceOrTaskLocal<_DiagnosticLoggingEnvironment?>(
        wrappedValue: nil
    )
}

extension _DiagnosticLoggingValues {
    static var isEnvironmentActive: Bool {
        environment.isValueFixed || environment._isTaskLocalValueActive
    }
}
