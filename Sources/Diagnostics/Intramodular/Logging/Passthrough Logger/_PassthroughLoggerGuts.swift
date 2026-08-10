//
// Copyright (c) Vatsal Manot
//

import Combine
import Foundation
@_spi(Internal) import Swallow

/// A logger that broadcasts its entries.
///
/// Structured local event stream first; OSLog sink second. Apple's store/query
/// story is too narrow to be the diagnostic source of truth.
@usableFromInline
final class _PassthroughLoggerGuts: ClientLoggerProtocol, @unchecked Sendable {
    typealias Source = PassthroughLogger.Source
    
    @usableFromInline
    typealias LogLevel = ClientLogLevel
    @usableFromInline
    typealias LogMessage = PassthroughLogger.Message
    @usableFromInline
    typealias LogEntry = PassthroughLogger.LogEntry
    
    private let lock = OSUnfairLock()
    private let parent: _PassthroughLoggerGuts?
    
    let source: PassthroughLogger.Source
    let scope: PassthroughLogger.Scope
    private var configuration: PassthroughLogger.Configuration
    /// Retain app-owned events for assertions/export. OSLogStore keeps making
    /// this basic support workflow platform- and entitlement-shaped.
    private var entries: [LogEntry] = []
    let entryPublisher = PassthroughSubject<LogEntry, Never>()
    
    private let defaultSink: _DefaultPassthroughLogSink
    private var textOutputCancellable: AnyCancellable?
    
    init(
        source: Source,
        configuration: PassthroughLogger.Configuration = .init(),
        defaultSink: _DefaultPassthroughLogSink = .default,
        textOutput: PassthroughLogger.ResolvedTextOutput? = nil
    ) {
        self.parent = nil
        self.source = source
        self.scope = .root
        self.configuration = configuration
        if textOutput != nil {
            self.configuration._dumpToConsole = false
        }
        self.defaultSink = defaultSink
        
        if let textOutput {
            self.textOutputCancellable = entryPublisher.sink { entry in
                textOutput.write(entry)
            }
        }
    }
    
    init(parent: _PassthroughLoggerGuts, scope: AnyLogScope) {
        self.parent = parent
        self.source = .logger(parent, scope: scope)
        self.scope = .child(parent: parent.scope, scope: scope)
        self.configuration = parent.configurationSnapshot
        self.defaultSink = parent.defaultSink
        self.textOutputCancellable = nil
    }
    
    @usableFromInline
    func emit(
        level: LogLevel,
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> DiagnosticLogMetadata?,
        file: String,
        function: String,
        line: UInt
    ) {
        let message = message()
        let entry = LogEntry(
            sourceCodeLocation: SourceCodeLocation(
                file: file,
                function: function,
                line: line,
                column: nil
            ),
            timestamp: Date(),
            scope: scope,
            level: level,
            message: message,
            metadata: metadata() ?? [:]
        )
        
        if _isDebugAssertConfiguration {
            if level == .error {
                runtimeIssue(message.description)
            }
        }
        
        emit(entry)
    }
    
    private func emit(
        _ entry: LogEntry
    ) {
        let emission = _PassthroughLogEmission(entry: entry)
        
        if let logEntryHandler = _TaskLocalValues._logEntryHandler {
            logEntryHandler(emission.entry)
        } else if _shouldEmitToLegacyDefaultSink {
            defaultSink._emitSynchronously(emission)
        }
        
        record(emission.entry)
    }
    
    private func record(
        _ entry: LogEntry
    ) {
        parent?.record(entry)
        
        lock.withCriticalScope {
            entries.append(entry)
        }
        
        entryPublisher.send(entry)
    }
}

// MARK: - Configuration

extension _PassthroughLoggerGuts {
    var configurationSnapshot: PassthroughLogger.Configuration {
        lock.withCriticalScope {
            configuration
        }
    }
    
    private var _shouldEmitToLegacyDefaultSink: Bool {
        lock.withCriticalScope {
            // Compatibility name: this now gates default sink emission.
            configuration._globallyResolved._dumpToConsole ?? true
        }
    }
    
    var _dumpToConsole: Bool? {
        get {
            lock.withCriticalScope {
                configuration._dumpToConsole
            }
        } set {
            lock.withCriticalScope {
                configuration._dumpToConsole = newValue
            }
        }
    }
}

// MARK: - Conformances

extension _PassthroughLoggerGuts: _LogExporting {
    public func exportLog() async throws -> some _LogExportArtifact {
        let entries = lock.withCriticalScope {
            self.entries
        }
        
        return _TextualLogDump(entries: entries.map {
            _TextualLogDump.Entry(
                timestamp: $0.timestamp,
                scope: $0.scope._toTextualLogDumpScope(),
                level: $0.level.description,
                message: $0.message.description
            )
        })
    }
}

extension _PassthroughLoggerGuts: ScopedLogger {
    @usableFromInline
    typealias Scope = AnyLogScope
    @usableFromInline
    typealias ScopedLogger = _PassthroughLoggerGuts
    
    @usableFromInline
    func scoped(to scope: Scope) throws -> ScopedLogger {
        _PassthroughLoggerGuts(parent: self, scope: scope)
    }
}

extension _PassthroughLoggerGuts: TextOutputStream {
    public func write(_ string: String) {
        emit(
            LogEntry(
                sourceCodeLocation: nil,
                timestamp: Date(),
                scope: scope,
                level: .info,
                message: .init(stringLiteral: string),
                metadata: [:]
            )
        )
    }
}

// MARK: - Helpers

extension PassthroughLogger.Scope {
    fileprivate func _toTextualLogDumpScope() -> [_TextualLogDump.Scope]? {
        switch self {
            case .root:
                return nil
            case .child(let parent, let scope):
                return (parent._toTextualLogDumpScope().map({ $0 }) ?? []) + [_TextualLogDump.Scope(rawValue: String(describing: scope))]
        }
    }
}
