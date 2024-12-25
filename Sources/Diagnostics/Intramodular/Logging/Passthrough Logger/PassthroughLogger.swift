//
// Copyright (c) Vatsal Manot
//

import Combine
import Foundation
import Swallow

extension PassthroughLogger {
    public struct Configuration: MergeOperatable {
        @TaskLocal static var global = Self()
        
        public var _dumpToConsole: Bool?
        
        public init(
            _dumpToConsole: Bool? = nil
        ) {
            self._dumpToConsole = _dumpToConsole
        }
        
        mutating public func mergeInPlace(
            with other: PassthroughLogger.Configuration
        ) {
            self._dumpToConsole = self._dumpToConsole ?? other._dumpToConsole
        }
        
        /// Resolved by merging with `global`.
        var _globallyResolved: Self {
            mergingInPlace(with: .global)
        }
    }
}

/// A logger that broadcasts its entries.
public final class PassthroughLogger: @unchecked Sendable, LoggerProtocol, ObservableObject {
    public typealias LogLevel = ClientLogLevel
    public typealias LogMessage = Message
    
    @usableFromInline
    let base: _PassthroughLoggerGuts
    
    public var entryPublisher: AnyPublisher<LogEntry, Never> {
        self.base.entryPublisher.eraseToAnyPublisher()
    }

    public var source: Source {
        self.base.source
    }

    private init(base: _PassthroughLoggerGuts) {
        self.base = base
    }
}

// MARK: - Initializers

extension PassthroughLogger {
    public convenience init(
        source: Source
    ) {
        self.init(base: _PassthroughLoggerGuts(source: source))
    }
     
    public convenience init<T: AnyObject & Logging>(
        source: T
    ) {
        self.init(source: .object(source))
    }
    
    public convenience init(
        print: Bool
    ) {
        self.init(
            base: _PassthroughLoggerGuts(
                source: .location(.unavailable),
                configuration: .init(_dumpToConsole: print)
            )
        )
    }
    
    public convenience init(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        column: UInt? = #column
    ) {
        self.init(
            source: .location(
                SourceCodeLocation(
                    file: file,
                    function: function,
                    line: line,
                    column: column
                )
            )
        )
    }
}

// MARK: - Conformances

extension PassthroughLogger: _LogExporting {
    public func exportLog() async throws -> some _LogFormat {
        try await base.exportLog()
    }
}

extension PassthroughLogger: ScopedLogger {
    public func scoped(
        to scope: AnyLogScope
    ) throws -> PassthroughLogger {
        PassthroughLogger(base: try base.scoped(to: scope))
    }
    
    public func scoped(
        to scope: some LogScope
    ) throws -> PassthroughLogger {
        PassthroughLogger(base: try base.scoped(to: AnyLogScope(_erasing: scope)))
    }
}

extension PassthroughLogger: TextOutputStream {
    public func write(_ string: String) {
        base.write(string)
    }
}

// MARK: - Extensions

extension PassthroughLogger {
    public var _dumpToConsole: Bool? {
        get {
            base.configuration._dumpToConsole
        } set {
            base.configuration._dumpToConsole = newValue
        }
    }
}
