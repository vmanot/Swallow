//
// Copyright (c) Vatsal Manot
//

import Swallow

/// A type that can log messages.
///
/// Relevant discussion:
/// - https://forums.swift.org/t/state-of-the-logging-swift-log-package/50943
///   Apple `Logger` and `swift-log` miss each other in the worst place:
///   OSLog-only privacy machinery, no redirectable backend, no real metadata.
/// - https://forums.swift.org/t/logging-levels-for-swifts-server-side-logging-apis-and-new-os-log-apis/20365
///   Two Apple-blessed logging worlds, no shared contract.
/// - https://forums.swift.org/t/collecting-design-requirements-for-a-general-purpose-logging-backend/72478
///   The missing backend basics: fanout, async dispatch, rotation, formatting,
///   OSLog mirroring, structured logging performance.
/// - https://forums.swift.org/t/proposal-slg-0005-logevent-loghandler-api/85217
///   `swift-log` belatedly grows an event envelope.
///
/// Keep the protocol below the backend fight. Levels and messages need a common
/// shape before OSLog, `swift-log`, tests, and exports can stop losing intent.
public protocol LoggerProtocol: Sendable {
    associatedtype LogLevel: LogLevelProtocol
    associatedtype LogMessage: LogMessageProtocol
    
    func log(
        level: LogLevel,
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> [String: Any]?,
        file: String,
        function: String,
        line: UInt
    )
}
