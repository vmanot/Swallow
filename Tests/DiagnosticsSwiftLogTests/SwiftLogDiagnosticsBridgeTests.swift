//
// Copyright (c) Vatsal Manot
//

import Diagnostics
import DiagnosticsSwiftLog
import Foundation
import Logging
import Testing

@Suite
struct SwiftLogDiagnosticsBridgeTests {
    @Test
    func diagnosticEventReachesSwiftLogWithoutFlatteningItsEnvelope() throws {
        let recorder = EventRecorder()
        let logger = Logger(label: "diagnostics-bridge") { _ in
            RecordingLogHandler(recorder: recorder)
        }

        emitPortableEvent(using: logger)

        let event = try #require(recorder.events.only)

        #expect(event.level == .notice)
        #expect(event.message.description == "Resolved release")
        #expect(event.metadata?["attempt"]?.description == "2")
        if case .array(let targets)? = event.metadata?["targets"] {
            #expect(targets.map(\.description) == ["arm64", "x86_64"])
        } else {
            Issue.record("Expected targets to remain structured array metadata")
        }
        #expect(event.file == "Bridge.swift")
        #expect(event.function == "release()")
        #expect(event.line == 42)
    }

    private func emitPortableEvent<L: LoggerProtocol>(
        using logger: L
    ) where L.LogLevel == Logger.Level, L.LogMessage == Logger.Message {
        logger.log(
            level: .notice,
            "Resolved release",
            metadata: [
                "attempt": 2,
                "targets": ["arm64", "x86_64"],
            ],
            file: "Bridge.swift",
            function: "release()",
            line: 42
        )
    }
}

private final class EventRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var recordedEvents: [LogEvent] = []

    var events: [LogEvent] {
        lock.withLock {
            recordedEvents
        }
    }

    func append(_ event: LogEvent) {
        lock.withLock {
            recordedEvents.append(event)
        }
    }
}

private struct RecordingLogHandler: LogHandler {
    let recorder: EventRecorder
    var metadataProvider: Logger.MetadataProvider?
    var metadata: Logger.Metadata = [:]
    var logLevel: Logger.Level = .trace

    init(recorder: EventRecorder) {
        self.recorder = recorder
        self.metadataProvider = nil
    }

    subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get {
            metadata[key]
        }
        set {
            metadata[key] = newValue
        }
    }

    func log(event: LogEvent) {
        recorder.append(event)
    }
}

extension Collection {
    fileprivate var only: Element? {
        count == 1 ? first : nil
    }
}
