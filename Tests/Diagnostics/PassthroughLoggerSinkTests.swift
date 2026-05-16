//
// Copyright (c) Vatsal Manot
//

import Combine
@_spi(Internal) @testable import Diagnostics
import Foundation
@_spi(Internal) import Swallow
import Testing

@Suite
final class PassthroughLoggerSinkTests {
    @Test
    func defaultConfigurationEmitsToDefaultSink() {
        let sink = RecordingSink()
        let logger = makeLogger(sink: sink)
        
        log("default", using: logger)
        
        #expect(sink.messages == ["default"])
    }
    
    @Test
    func dumpToConsoleTrueEmitsToDefaultSink() {
        let sink = RecordingSink()
        let logger = makeLogger(
            configuration: .init(_dumpToConsole: true),
            sink: sink
        )
        
        log("enabled", using: logger)
        
        #expect(sink.messages == ["enabled"])
    }
    
    @Test
    func dumpToConsoleFalseSuppressesDefaultSink() async throws {
        let sink = RecordingSink()
        let logger = makeLogger(
            configuration: .init(_dumpToConsole: false),
            sink: sink
        )
        
        log("suppressed", using: logger)
        
        #expect(sink.messages.isEmpty)
        
        let dump = try await logger.exportLog()._textualDump()
        
        #expect(dump.entries.map(\.message) == ["suppressed"])
    }
    
    @Test
    func globalFallbackIsResolvedAtEmissionTime() {
        let sink = RecordingSink()
        let logger = makeLogger(
            configuration: .init(_dumpToConsole: nil),
            sink: sink
        )
        
        PassthroughLogger.Configuration.$global.withValue(.init(_dumpToConsole: false)) {
            log("globally-disabled", using: logger)
        }
        
        PassthroughLogger.Configuration.$global.withValue(.init(_dumpToConsole: true)) {
            log("globally-enabled", using: logger)
        }
        
        #expect(sink.messages == ["globally-enabled"])
    }
    
    @Test
    func scopedLoggerSnapshotsParentLocalConfiguration() {
        let sink = RecordingSink()
        let parent = makeLogger(
            configuration: .init(_dumpToConsole: false),
            sink: sink
        )
        let child = try! parent.scoped(to: AnyLogScope(erasing: FunctionLogScope(function: "child")))
        
        parent._dumpToConsole = true
        
        log("parent", using: parent)
        log("child", using: child)
        
        #expect(sink.messages == ["parent"])
    }
    
    @Test
    func scopedLoggerWithInheritedNilStillUsesDynamicGlobalFallback() {
        let sink = RecordingSink()
        let parent = makeLogger(
            configuration: .init(_dumpToConsole: nil),
            sink: sink
        )
        let child = try! parent.scoped(to: AnyLogScope(erasing: FunctionLogScope(function: "child")))
        
        PassthroughLogger.Configuration.$global.withValue(.init(_dumpToConsole: false)) {
            log("disabled-child", using: child)
        }
        
        PassthroughLogger.Configuration.$global.withValue(.init(_dumpToConsole: true)) {
            log("enabled-child", using: child)
        }
        
        #expect(sink.messages == ["enabled-child"])
    }
    
    @Test
    func logTrackingInterceptsDefaultSinkEmission() {
        let sink = RecordingSink()
        let tracked = RecordingEntries()
        let logger = makeLogger(sink: sink)
        
        _withLogTracking(
            perform: {
                self.log("tracked", using: logger)
            },
            handler: { entry in
                tracked.append(entry)
            }
        )
        
        #expect(sink.messages.isEmpty)
        #expect(tracked.messages == ["tracked"])
    }
    
    @Test
    func parentPublisherReceivesChildEntriesBeforeChildPublisher() {
        let sink = RecordingSink()
        let parent = makeLogger(sink: sink)
        let child = try! parent.scoped(to: AnyLogScope(erasing: FunctionLogScope(function: "child")))
        let parentEntries = RecordingEntries()
        let childEntries = RecordingEntries()
        var cancellables: Set<AnyCancellable> = []
        
        parent.entryPublisher.sink { entry in
            parentEntries.append(entry)
        }.store(in: &cancellables)
        
        child.entryPublisher.sink { entry in
            childEntries.append(entry)
        }.store(in: &cancellables)
        
        log("child-entry", using: child)
        
        #expect(parentEntries.messages == ["child-entry"])
        #expect(childEntries.messages == ["child-entry"])
    }
    
    @Test
    func textOutputStreamUsesSameEmissionPath() {
        let sink = RecordingSink()
        let logger = makeLogger(sink: sink)
        
        logger.write("streamed")
        
        #expect(sink.messages == ["streamed"])
    }
    
    @Test
    func plainTextFormatUsesCapturedLogEntryWithoutEmissionCarrier() {
        let sink = RecordingSink()
        let logger = makeLogger(sink: sink)
        let entries = RecordingEntries()
        
        _withLogTracking(
            perform: {
                self.log("plain", using: logger)
            },
            handler: { entry in
                entries.append(entry)
            }
        )
        
        #expect(sink.messages.isEmpty)
        #expect(entries.formattedMessages(using: .plain) == ["plain"])
    }
    
    @Test
    func textOutputFormatIndentsFromScopePath() {
        let sink = RecordingSink()
        let root = makeLogger(sink: sink)
        let child = try! root.scoped(to: AnyLogScope(erasing: FunctionLogScope(function: "child")))
        let grandchild = try! child.scoped(to: AnyLogScope(erasing: FunctionLogScope(function: "grandchild")))
        let entries = RecordingEntries()
        
        _withLogTracking(
            perform: {
                self.log("root", using: root)
                self.log("child", using: child)
                self.log("grandchild", using: grandchild)
            },
            handler: { entry in
                entries.append(entry)
            }
        )
        
        let format = LogEntryTextFormat.commandLine
        
        #expect(entries.formattedMessages(using: format) == [
            "root",
            "  child",
            "    grandchild"
        ])
    }
    
    @Test
    func logScopeTextRepresentationFallsBackToDescription() {
        let scope = AnyLogScope(erasing: LegacyTestScope(name: "legacy"))
        
        #expect(scope.textRepresentation.description == "legacy")
        #expect(scope.textRepresentation.segments.map(\.description) == ["legacy"])
    }
    
    @Test
    func logScopeTextRepresentationForwardsCustomRepresentation() {
        let scope = AnyLogScope(erasing: StructuredTestScope(segments: ["workspace", "Swallow"]))
        
        #expect(scope.textRepresentation.description == "workspace Swallow")
        #expect(scope.textRepresentation.segments.map(\.description) == ["workspace", "Swallow"])
    }
    
    @Test
    func passthroughLoggerScopeTextRepresentationsPreservePathOrder() {
        let root = makeLogger(sink: RecordingSink())
        let child = try! root.scoped(to: AnyLogScope(erasing: StructuredTestScope(segments: ["workspace", "App"])))
        let grandchild = try! child.scoped(to: AnyLogScope(erasing: FunctionLogScope(function: "build")))
        
        #expect(grandchild.scope.textRepresentations.map(\.description) == [
            "workspace App",
            "build"
        ])
    }
    
    @Test
    func textOutputFormatIndentsMultilineMessages() {
        let sink = RecordingSink()
        let root = makeLogger(sink: sink)
        let child = try! root.scoped(to: AnyLogScope(erasing: FunctionLogScope(function: "child")))
        let entries = RecordingEntries()
        
        _withLogTracking(
            perform: {
                self.log("first\nsecond", using: child)
            },
            handler: { entry in
                entries.append(entry)
            }
        )
        
        #expect(entries.formattedMessages(using: .commandLine) == [
            "  first\n  second"
        ])
    }
    
    @Test
    func linePrefixTransformCanPrefixOnlyFirstLine() {
        let sink = RecordingSink()
        let root = makeLogger(sink: sink)
        let child = try! root.scoped(to: AnyLogScope(erasing: FunctionLogScope(function: "child")))
        let entries = RecordingEntries()
        
        _withLogTracking(
            perform: {
                self.log("first\nsecond", using: child)
            },
            handler: { entry in
                entries.append(entry)
            }
        )
        
        let format = LogEntryTextFormat.linePrefixed(
            prefix: ScopePathLogEntryIndentation(unit: "  "),
            prefixesMultilineMessages: false
        )
        
        #expect(entries.formattedMessages(using: format) == [
            "  first\nsecond"
        ])
    }
    
    @Test
    func textOutputFormatAcceptsCustomLinePrefixStrategy() {
        let sink = RecordingSink()
        let root = makeLogger(sink: sink)
        let child = try! root.scoped(to: AnyLogScope(erasing: FunctionLogScope(function: "child")))
        let entries = RecordingEntries()
        
        _withLogTracking(
            perform: {
                self.log("custom", using: child)
            },
            handler: { entry in
                entries.append(entry)
            }
        )
        
        let format = LogEntryTextFormat.linePrefixed(
            prefix: ScopeNamePrefix()
        )
        
        #expect(entries.formattedMessages(using: format) == [
            "[child] custom"
        ])
    }
    
    @Test
    func textOutputFormatAcceptsCustomIndentationStrategy() {
        let sink = RecordingSink()
        let root = makeLogger(sink: sink)
        let child = try! root.scoped(to: AnyLogScope(erasing: FunctionLogScope(function: "child")))
        let entries = RecordingEntries()
        
        _withLogTracking(
            perform: {
                self.log("custom", using: child)
            },
            handler: { entry in
                entries.append(entry)
            }
        )
        
        let format = LogEntryTextFormat.linePrefixed(
            prefix: ArrowIndentation()
        )
        
        #expect(entries.formattedMessages(using: format) == [
            "→ custom"
        ])
    }
    
    @Test
    func textOutputTransformsComposeInOrder() {
        let sink = RecordingSink()
        let logger = makeLogger(sink: sink)
        let entries = RecordingEntries()
        
        _withLogTracking(
            perform: {
                self.log("composed", using: logger)
            },
            handler: { entry in
                entries.append(entry)
            }
        )
        
        let format = LogEntryTextFormat(
            transforms: [
                LinePrefixLogEntryTextTransform(prefix: LiteralPrefix("[one] ")),
                LinePrefixLogEntryTextTransform(prefix: LiteralPrefix("[two] "))
            ]
        )
        
        #expect(entries.formattedMessages(using: format) == [
            "[two] [one] composed"
        ])
    }
    
    @Test
    func intentionallyUnspecifiedSourceHasStableDescription() {
        #expect(PassthroughLogger.Source.intentionallyUnspecified().description == "<intentionally-unspecified>")
    }
    
    @Test
    func constructionTimeTextOutputPublishesRootAndChildEntriesOnce() {
        let output = RecordingTextOutput()
        let logger = PassthroughLogger(
            source: .intentionallyUnspecified(),
            textOutput: .custom(format: .plain) { text in
                output.append(text)
            }
        )
        let child = logger.childLogger(scopedTo: FunctionLogScope(function: "child"))
        
        logger.info("root")
        child.info("child")
        
        #expect(output.lines == ["root", "child"])
        #expect(logger._dumpToConsole == false)
    }
    
    @Test
    func diagnosticLoggingEnvironmentTaskLocalScopeIsDetectedAndRestored() {
        #expect(!_DiagnosticLoggingValues.isEnvironmentActive)
        
        _DiagnosticLoggingEnvironment.withEnvironment(.init()) {
            #expect(_DiagnosticLoggingValues.isEnvironmentActive)
        }
        
        #expect(!_DiagnosticLoggingValues.isEnvironmentActive)
    }
    
    @Test
    func globalSetOnceOrTaskLocalUsesDefaultNestedTaskLocalAndFixedValues() {
        let value = _GlobalSetOnceOrTaskLocal<Int>(wrappedValue: 1)
        
        #expect(value.wrappedValue == 1)
        
        value.withValue(2) {
            #expect(value.wrappedValue == 2)
            
            value.withValue(3) {
                #expect(value.wrappedValue == 3)
            }
            
            #expect(value.wrappedValue == 2)
        }
        
        #expect(value.wrappedValue == 1)
        
        value.fixValue(4)
        
        #expect(value.wrappedValue == 4)
        #expect(value.isValueFixed)
    }
    
    @Test
    func globalSetOnceOrTaskLocalPreservesOptionalNilOverrides() {
        let value = _GlobalSetOnceOrTaskLocal<Int?>(wrappedValue: 1)
        
        value.withValue(nil) {
            #expect(value.wrappedValue == nil)
        }
        
        #expect(value.wrappedValue == 1)
    }
    
    @Test
    func globalSetOnceOrTaskLocalSupportsAsyncOverrides() async {
        let value = _GlobalSetOnceOrTaskLocal<String>(wrappedValue: "default")
        
        await value.withValue("async") {
            await Task.yield()
            
            #expect(value.wrappedValue == "async")
        }
        
        #expect(value.wrappedValue == "default")
    }
    
    @Test
    func scopePathTextPrefixSupportsLeafAndFullPath() {
        let sink = RecordingSink()
        let root = makeLogger(sink: sink)
        let child = try! root.scoped(to: AnyLogScope(erasing: FunctionLogScope(function: "child")))
        let grandchild = try! child.scoped(to: AnyLogScope(erasing: FunctionLogScope(function: "grandchild")))
        let entries = RecordingEntries()
        
        _withLogTracking(
            perform: {
                self.log("message", using: grandchild)
            },
            handler: { entry in
                entries.append(entry)
            }
        )
        
        let leaf = LogEntryTextFormat.linePrefixed(
            prefix: ScopePathLogEntryTextPrefix(selection: .leaf, suffix: ": ")
        )
        let fullPath = LogEntryTextFormat.linePrefixed(
            prefix: ScopePathLogEntryTextPrefix(selection: .fullPath(separator: " / "), suffix: ": ")
        )
        
        #expect(entries.formattedMessages(using: leaf) == [
            "grandchild: message"
        ])
        #expect(entries.formattedMessages(using: fullPath) == [
            "child / grandchild: message"
        ])
    }
    
    private func makeLogger(
        configuration: PassthroughLogger.Configuration = .init(),
        sink: RecordingSink
    ) -> _PassthroughLoggerGuts {
        _PassthroughLoggerGuts(
            source: .location(.unavailable),
            configuration: configuration,
            defaultSink: _DefaultPassthroughLogSink(sink)
        )
    }
    
    private func log(
        _ message: String,
        using logger: _PassthroughLoggerGuts
    ) {
        logger.log(
            level: .info,
            .init(stringLiteral: message),
            metadata: nil,
            file: #filePath,
            function: #function,
            line: #line
        )
    }
    
    private final class RecordingSink: _SynchronousPassthroughLogSink, @unchecked Sendable {
        private let lock = OSUnfairLock()
        private var emissions: [_PassthroughLogEmission] = []
        
        var messages: [String] {
            lock.withCriticalScope {
                emissions.map(\.entry.message.description)
            }
        }
        
        func _emitSynchronously(
            _ emission: _PassthroughLogEmission
        ) {
            lock.withCriticalScope {
                emissions.append(emission)
            }
        }
    }
    
    private final class RecordingEntries: @unchecked Sendable {
        private let lock = OSUnfairLock()
        private var entries: [PassthroughLogger.LogEntry] = []
        
        var messages: [String] {
            lock.withCriticalScope {
                entries.map(\.message.description)
            }
        }
        
        func formattedMessages(
            using format: LogEntryTextFormat
        ) -> [String] {
            lock.withCriticalScope {
                entries.map { $0.formatted(using: format) }
            }
        }
        
        func append(
            _ entry: PassthroughLogger.LogEntry
        ) {
            lock.withCriticalScope {
                entries.append(entry)
            }
        }
    }
    
    private final class RecordingTextOutput: @unchecked Sendable {
        private let lock = OSUnfairLock()
        private var storage: [String] = []
        
        var lines: [String] {
            lock.withCriticalScope {
                storage
            }
        }
        
        func append(
            _ line: String
        ) {
            lock.withCriticalScope {
                storage.append(line)
            }
        }
    }
    
    private struct ScopeNamePrefix: LogEntryLinePrefixStrategy {
        func prefix(
            for entry: PassthroughLogger.LogEntry
        ) -> String {
            guard let lastScope = entry.scope.path.last else {
                return ""
            }
            
            return "[\(lastScope.description)] "
        }
    }
    
    private struct ArrowIndentation: LogEntryIndentationStrategy {
        func prefix(
            for entry: PassthroughLogger.LogEntry
        ) -> String {
            String(repeating: "→ ", count: entry.scope.path.count)
        }
    }
    
    private struct LiteralPrefix: LogEntryLinePrefixStrategy {
        let value: String
        
        init(
            _ value: String
        ) {
            self.value = value
        }
        
        func prefix(
            for entry: PassthroughLogger.LogEntry
        ) -> String {
            value
        }
    }
    
    private struct LegacyTestScope: Hashable, LogScope {
        let name: String
        
        var description: String {
            name
        }
    }
    
    private struct StructuredTestScope: Hashable, LogScope, LogScopeTextRepresentable {
        let segments: [String]
        
        var description: String {
            segments.joined(separator: "/")
        }
        
        var logScopeTextRepresentation: LogScopeTextRepresentation {
            LogScopeTextRepresentation(
                segments: segments.map {
                    LogScopeTextRepresentation.Segment($0)
                }
            )
        }
    }
}
