//
// Copyright (c) Vatsal Manot
//

import Swallow

/// Output and context inherited by loggers created during an operation.
///
/// This lets a library continue to use its ordinary `Logging.logger` while an
/// executable selects the concrete destination and text presentation at its
/// boundary.
public struct DiagnosticLoggingEnvironment: Sendable {
    public var textOutput: PassthroughLogger.ResolvedTextOutput?

    public init(
        textOutput: PassthroughLogger.ResolvedTextOutput? = nil
    ) {
        self.textOutput = textOutput
    }
}

public enum GlobalDiagnosticLoggingEnvironment {
    public static var isBootstrapped: Bool {
        _DiagnosticLoggingValues.environment.isValueFixed
    }

    public static func bootstrap(
        _ environment: DiagnosticLoggingEnvironment
    ) {
        _DiagnosticLoggingValues.environment.fixValue(environment)
    }
}

extension DiagnosticLoggingEnvironment {
    public static func withValue<R>(
        _ environment: Self,
        operation: () throws -> R
    ) rethrows -> R {
        try _DiagnosticLoggingValues.environment.withValue(environment) {
            try operation()
        }
    }

    public static func withValue<R>(
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
    static let environment = _GlobalSetOnceOrTaskLocal<DiagnosticLoggingEnvironment?>(
        wrappedValue: nil
    )
}

extension _DiagnosticLoggingValues {
    static var isEnvironmentActive: Bool {
        environment.isValueFixed || environment._isTaskLocalValueActive
    }
}
