//
// Copyright (c) Vatsal Manot
//

@_spi(Internal) import Swallow
import Testing

@testable import Diagnostics

@Suite
struct LoggerProtocolErgonomicsTests {
    @Test
    func portableMetadataAndOptionalMessagesSurviveEmission() {
        let logger = RecordingLogger<ClientLogLevel>()
        let absent: PassthroughLogger.Message? = nil
        let rendered = "Rendered cask"

        logger.info(
            "Resolved release",
            metadata: [
                "attempt": 2,
                "targets": ["arm64", "x86_64"],
                "context": ["mode": "dry-run"],
            ]
        )
        logger.info(ifPresent: absent)
        logger.info(verbatim: rendered)

        #expect(logger.events.map(\.message) == ["Resolved release", "Rendered cask"])
        #expect(
            logger.events.first?.metadata == [
                "attempt": 2,
                "targets": ["arm64", "x86_64"],
                "context": ["mode": "dry-run"],
            ]
        )
    }

    @Test
    func errorLoggingReturnsTheOriginalErrorAndSkipsNil() {
        let logger = RecordingLogger<ClientLogLevel>()
        let returned = logger.error(TestError.failed)
        let absent: TestError? = nil

        #expect(returned == .failed)
        #expect(logger.error(ifPresent: absent) == nil)
        #expect(logger.events.map(\.message) == ["failed"])
    }

    @Test
    func serverLoggerExposesTraceWithoutInventingFault() {
        let logger = RecordingLogger<ServerLogLevel>()

        logger.trace("Resolve manifest")
        logger.critical("Release failed")

        #expect(logger.events.map(\.level) == ["trace", "critical"])
    }

    @Test
    func legacyAnyMetadataUsesReifiedConversionBeforeDescriptionFallback() {
        let legacy: [String: Any] = [
            "artifact": ArtifactMetadata(name: "swift-brew", version: "1.0.0")
        ]
        let converted = DiagnosticLogMetadata(describingLegacyMetadata: legacy)

        #expect(
            converted["artifact"] == [
                "name": "swift-brew",
                "version": "1.0.0",
            ]
        )
    }

    @Test
    func fullProtocolRequirementDispatchesToTheReifiedLoggerWitness() {
        let logger = WitnessLogger()

        emitInfo(using: logger)

        #expect(logger.receivedMessages == ["Reified message"])
        #expect(logger.emittedMessages.isEmpty)
    }

    private func emitInfo<L: ClientLoggerProtocol>(
        using logger: L
    ) where L.LogMessage == PassthroughLogger.Message {
        logger.info(
            "Reified message",
            metadata: nil,
            file: "Reified.swift",
            function: "emitInfo(using:)",
            line: 1
        )
    }
}

private enum TestError: Error, Equatable {
    case failed
}

private struct ArtifactMetadata: DiagnosticLogMetadataValueConvertible {
    let name: String
    let version: String

    var diagnosticLogMetadataValue: DiagnosticLogMetadataValue {
        [
            "name": .init(name),
            "version": .init(version),
        ]
    }
}

private final class RecordingLogger<Level: LogLevelProtocol>: LoggerProtocol, @unchecked Sendable {
    typealias LogLevel = Level
    typealias LogMessage = PassthroughLogger.Message

    struct Event: Sendable {
        let level: String
        let message: String
        let metadata: DiagnosticLogMetadata
    }

    private let lock = OSUnfairLock()
    private var recordedEvents: [Event] = []

    var events: [Event] {
        lock.withCriticalScope {
            recordedEvents
        }
    }

    func emit(
        level: Level,
        _ message: @autoclosure () -> PassthroughLogger.Message,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    ) {
        let event = Event(
            level: level.stringValue,
            message: message().description,
            metadata: metadata() ?? [:]
        )

        lock.withCriticalScope {
            recordedEvents.append(event)
        }
    }
}

extension RecordingLogger: ClientLoggerProtocol where Level: ClientLogLevelProtocol {

}

extension RecordingLogger: ServerLoggerProtocol where Level: ServerLogLevelProtocol {

}

private final class WitnessLogger: ClientLoggerProtocol, @unchecked Sendable {
    typealias LogLevel = ClientLogLevel
    typealias LogMessage = PassthroughLogger.Message

    private let lock = OSUnfairLock()
    private var received: [String] = []
    private var emitted: [String] = []

    var receivedMessages: [String] {
        lock.withCriticalScope { received }
    }

    var emittedMessages: [String] {
        lock.withCriticalScope { emitted }
    }

    func emit(
        level: ClientLogLevel,
        _ message: @autoclosure () -> PassthroughLogger.Message,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    ) {
        let message = message().description
        lock.withCriticalScope {
            emitted.append(message)
        }
    }

    func info(
        _ message: @autoclosure () -> PassthroughLogger.Message,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    ) {
        let message = message().description
        lock.withCriticalScope {
            received.append(message)
        }
    }
}
