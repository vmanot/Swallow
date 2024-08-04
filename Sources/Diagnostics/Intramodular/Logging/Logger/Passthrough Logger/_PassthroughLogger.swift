//
// Copyright (c) Vatsal Manot
//

import Combine
import Foundation
@_spi(Internal) import Swallow

/// A logger that broadcasts its entries.
@usableFromInline
final class _PassthroughLogger: LoggerProtocol, @unchecked Sendable {
    typealias Source = PassthroughLogger.Source
    
    @usableFromInline
    typealias LogLevel = ClientLogLevel
    @usableFromInline
    typealias LogMessage = PassthroughLogger.Message
    @usableFromInline
    typealias LogEntry = PassthroughLogger.LogEntry
    
    private let lock = OSUnfairLock()
    private let parent: _PassthroughLogger?
    
    var source: PassthroughLogger.Source
    var scope: PassthroughLogger.Scope
    var configuration: PassthroughLogger.Configuration
    var entries: [LogEntry] = []
    var entryPublisher = PassthroughSubject<LogEntry, Never>()
    
    private lazy var _platformLogger: OSLoggerProtocol? = {
        if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
            return OSLogger(subsystem: Bundle.main.bundleIdentifier ?? "<main>", category: "Diagnostics")
        } else {
            return nil
        }
    }()
    
    init(
        source: Source,
        configuration: PassthroughLogger.Configuration = .init()
    ) {
        self.parent = nil
        self.source = source
        self.scope = .root
        self.configuration = configuration
    }
    
    init(parent: _PassthroughLogger, scope: AnyLogScope) {
        self.parent = parent
        self.source = .logger(parent, scope: scope)
        self.scope = .child(parent: parent.scope, scope: scope)
        self.configuration = parent.configuration
    }
    
    @usableFromInline
    func log(
        level: LogLevel,
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> [String: Any]?,
        file: String,
        function: String,
        line: UInt
    ) {
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
            message: message()
        )
        
        if _isDebugAssertConfiguration {
            if level == .error {
                runtimeIssue(message().description)
            }
        }
        
        if let logEntryHandler = _TaskLocalValues._logEntryHandler {
            logEntryHandler(entry)
        } else {
            let dumptoConsole = (configuration._dumpToConsole ?? (PassthroughLogger.Configuration.global._dumpToConsole ?? true))
            
            if dumptoConsole, #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
                if let _platformLogger = _platformLogger as? OSLogger {
                    _platformLogger._log(level: level, message().description)
                }
            }
        }
        
        lock.withCriticalScope {
            parent?.entries.append(entry)
            
            entries.append(entry)
        }
    }
}

// MARK: - Conformances

extension _PassthroughLogger: _LogExporting {
    public func exportLog() async throws -> some _LogFormat {
        _TextualLogDump(entries: entries.map {
            _TextualLogDump.Entry(
                timestamp: $0.timestamp,
                scope: scope._toTextualLogDumpScope(),
                level: $0.level.description,
                message: $0.message.description
            )
        })
    }
}

extension _PassthroughLogger: ScopedLogger {
    @usableFromInline
    typealias Scope = AnyLogScope
    @usableFromInline
    typealias ScopedLogger = _PassthroughLogger
    
    @usableFromInline
    func scoped(to scope: Scope) throws -> ScopedLogger {
        _PassthroughLogger(parent: self, scope: scope)
    }
}

extension _PassthroughLogger: TextOutputStream {
    public func write(_ string: String) {
        entries.append(
            .init(
                sourceCodeLocation: nil,
                timestamp: Date(),
                scope: .root,
                level: .info,
                message: .init(stringLiteral: string)
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
