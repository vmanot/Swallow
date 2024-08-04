//
// Copyright (c) Vatsal Manot
//

import Combine
import Foundation
import Swallow

/// A logger that broadcasts its entries.
public final class PassthroughLogger: @unchecked Sendable, LoggerProtocol, ObservableObject {
    public typealias LogLevel = ClientLogLevel
    public typealias LogMessage = Message
    
    @usableFromInline
    let base: _PassthroughLogger
    
    public var entryPublisher: AnyPublisher<LogEntry, Never> {
        base.entryPublisher.eraseToAnyPublisher()
    }
    
    private init(base: _PassthroughLogger) {
        self.base = base
    }
    
    public var source: Source {
        base.source
    }
}

// MARK: - Initializers

extension PassthroughLogger {
    public convenience init(
        source: Source
    ) {
        self.init(base: _PassthroughLogger(source: source))
    }
    
    public convenience init(
        print: Bool
    ) {
        self.init(
            base: _PassthroughLogger(
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
    public func scoped(to scope: AnyLogScope) throws -> PassthroughLogger {
        PassthroughLogger(base: try base.scoped(to: scope))
    }
    
    public func scoped(to scope: some LogScope) throws -> PassthroughLogger {
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
