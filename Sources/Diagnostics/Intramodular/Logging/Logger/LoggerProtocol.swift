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
///
/// Swift does not permit default arguments on protocol requirements. The
/// matching extension methods provide caller-site defaults and route through
/// `emit` or another required backend-sensitive witness. A reified logger can
/// also implement any complete overload below when it needs level-specific
/// behavior.
public protocol LoggerProtocol: Sendable {
    associatedtype LogLevel: LogLevelProtocol
    associatedtype LogMessage: LogMessageProtocol

    func emit(
        level: LogLevel,
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )

    func log(
        level: LogLevel,
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )
    func log(
        level: LogLevel,
        ifPresent message: @autoclosure () -> LogMessage?,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )
    func log(
        level: LogLevel,
        verbatim message: @autoclosure () -> String?,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )

    func debug(
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )
    func debug(
        ifPresent message: @autoclosure () -> LogMessage?,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )
    func debug(
        verbatim message: @autoclosure () -> String?,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )

    func error(
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )
    func error(
        ifPresent message: @autoclosure () -> LogMessage?,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )
    func error(
        verbatim message: @autoclosure () -> String?,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    ) -> (any Error)?
    func error<E: Error>(
        _ error: @autoclosure () -> E,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    ) -> E
    func error<E: Error>(
        ifPresent error: @autoclosure () -> E?,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    ) -> E?
}

/// A logger whose level model follows Apple's client-side severity set.
public protocol ClientLoggerProtocol: LoggerProtocol where LogLevel: ClientLogLevelProtocol {
    func info(
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )
    func info(
        ifPresent message: @autoclosure () -> LogMessage?,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )
    func info(
        verbatim message: @autoclosure () -> String?,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )

    func notice(
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )
    func notice(
        ifPresent message: @autoclosure () -> LogMessage?,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )
    func notice(
        verbatim message: @autoclosure () -> String?,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )

    func warning(
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )
    func warning(
        ifPresent message: @autoclosure () -> LogMessage?,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )
    func warning(
        verbatim message: @autoclosure () -> String?,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )
    func warning<E: Error>(
        _ error: @autoclosure () -> E,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    ) -> E
    func warning<E: Error>(
        ifPresent error: @autoclosure () -> E?,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    ) -> E?

    func fault(
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )
    func fault(
        ifPresent message: @autoclosure () -> LogMessage?,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )
    func fault(
        verbatim message: @autoclosure () -> String?,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )

    func critical(
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )
    func critical(
        ifPresent message: @autoclosure () -> LogMessage?,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )
    func critical(
        verbatim message: @autoclosure () -> String?,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )
}

/// A logger whose level model follows swift-log's server-side severity set.
public protocol ServerLoggerProtocol: LoggerProtocol where LogLevel: ServerLogLevelProtocol {
    func trace(
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )
    func trace(
        ifPresent message: @autoclosure () -> LogMessage?,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )
    func trace(
        verbatim message: @autoclosure () -> String?,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )

    func info(
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )
    func info(
        ifPresent message: @autoclosure () -> LogMessage?,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )
    func info(
        verbatim message: @autoclosure () -> String?,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )

    func notice(
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )
    func notice(
        ifPresent message: @autoclosure () -> LogMessage?,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )
    func notice(
        verbatim message: @autoclosure () -> String?,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )

    func warning(
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )
    func warning(
        ifPresent message: @autoclosure () -> LogMessage?,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )
    func warning(
        verbatim message: @autoclosure () -> String?,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )

    func critical(
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )
    func critical(
        ifPresent message: @autoclosure () -> LogMessage?,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )
    func critical(
        verbatim message: @autoclosure () -> String?,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    )
}
