//
// Copyright (c) Vatsal Manot
//

import Combine
import Foundation
@_spi(Internal) import Swallow

/// A logger that broadcasts its entries.
final class _PassthroughLogger: LoggerProtocol, @unchecked Sendable {
    typealias Source = PassthroughLogger.Source
    
    typealias LogLevel = ClientLogLevel
    typealias LogMessage = PassthroughLogger.Message
    typealias LogEntry = PassthroughLogger.LogEntry
    
    private let lock = OSUnfairLock()
    
    private let parent: _PassthroughLogger?
    private let source: PassthroughLogger.Source
    private let scope: PassthroughLoggerScope
    
    var configuration: PassthroughLogger.Configuration
    
    var entries: [LogEntry] = []
    
    init(source: Source) {
        self.parent = nil
        self.source = source
        self.scope = .root
        self.configuration = .init()
    }
    
    init(parent: _PassthroughLogger, scope: AnyLogScope) {
        self.parent = parent
        self.source = .logger(parent)
        self.scope = .child(parent: parent.scope, scope: scope)
        self.configuration = parent.configuration
    }
    
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
        
        parent?.entries.append(entry)
        
        if _isDebugBuild {
            if configuration.dumpToConsole || PassthroughLogger.GlobalConfiguration.dumpToConsole {
                print("[\(source.description)] \(message())")
            }
        }

        lock.withCriticalScope {
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
    typealias Scope = AnyLogScope
    typealias ScopedLogger = _PassthroughLogger
    
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

extension PassthroughLoggerScope {
    fileprivate func _toTextualLogDumpScope() -> [_TextualLogDump.Scope]? {
        switch self {
            case .root:
                return nil
            case .child(let parent, let scope):
                return (parent._toTextualLogDumpScope().map({ $0 }) ?? []) + [_TextualLogDump.Scope(rawValue: String(describing: scope))]
        }
    }
}
