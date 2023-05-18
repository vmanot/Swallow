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
    
    private let base: _PassthroughLogger
    
    private init(base: _PassthroughLogger) {
        self.base = base
    }
    
    public convenience init(source: Source) {
        self.init(base: .init(source: source))
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
    
    public func log(
        level: LogLevel,
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> [String: Any]?,
        file: String,
        function: String,
        line: UInt
    ) {
        if Thread.isMainThread {
            objectWillChange.send()
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.objectWillChange.send()
            }
        }
        
        if _isDebugAssertConfiguration {
            if level == .error {
                runtimeIssue(message().description)
            }
        }
        
        base.log(
            level: level,
            message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }
}

extension PassthroughLogger: _LogExporting {
    public func exportLog() async throws -> some _LogFormat {
        try await base.exportLog()
    }
}

// MARK: - Conformances

extension PassthroughLogger: ScopedLogger {
    public func scoped(to scope: AnyLogScope) throws -> PassthroughLogger {
        PassthroughLogger(base: try base.scoped(to: scope))
    }
}

extension PassthroughLogger: TextOutputStream {
    public func write(_ string: String) {
        base.write(string)
    }
}

// MARK: - Extensions

extension PassthroughLogger {
    public var dumpToConsole: Bool {
        get {
            base.configuration.dumpToConsole
        } set {
            base.configuration.dumpToConsole = newValue
        }
    }
}

// MARK: - Auxiliary

extension PassthroughLogger {
    public struct Message: Codable, CustomStringConvertible, Hashable, LogMessageProtocol {
        public typealias StringLiteralType = String
        
        private var rawValue: String
        
        public var description: String {
            rawValue
        }
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(stringLiteral value: String) {
            self.rawValue = value
        }
        
        public init(from decoder: Decoder) throws {
            try self.init(rawValue: .init(from: decoder))
        }
        
        public func encode(to encoder: Encoder) throws {
            try rawValue.encode(to: encoder)
        }
    }
    
    public struct LogEntry: Hashable {
        public let sourceCodeLocation: SourceCodeLocation?
        public let timestamp: Date
        public let scope: PassthroughLoggerScope
        public let level: LogLevel
        public let message: LogMessage
    }
    
    public struct Source: CustomStringConvertible {
        public enum Content {
            case sourceCodeLocation(SourceCodeLocation)
            case logger(any LoggerProtocol)
            case something(Any)
            case object(Weak<AnyObject>)
        }
        
        private let content: Content
        
        public var description: String {
            switch content {
                case .sourceCodeLocation(let location):
                    return location.description
                case .logger(let logger):
                    return String(describing: logger)
                case .something(let value):
                    return String(describing: value)
                case .object(let object):
                    if let object = object.value {
                        return String(describing: object)
                    } else {
                        return "(null)"
                    }
            }
        }
        
        private init(content: Content) {
            self.content = content
        }
        
        public static func location(_ location: SourceCodeLocation) -> Self {
            Self(content: .sourceCodeLocation(location))
        }
        
        public static func logger(_ logger: any LoggerProtocol) -> Self {
            Self(content: .logger(logger))
        }
        
        public static func object(_ object: AnyObject) -> Self {
            Self(content: .object(Weak(object)))
        }
        
        public static func something(_ thing: Any) -> Self {
            if isClass(type(of: thing)) {
                return .object(thing as AnyObject)
            } else {
                return .init(content: .something(thing))
            }
        }
    }
    
    public struct Configuration {
        public var dumpToConsole: Bool = false
    }
}

extension PassthroughLogger {
    enum GlobalConfiguration {
        @TaskLocal
        static var dumpToConsole: Bool = false
    }
}

extension PassthroughLogger {
    /// Executes the given closure and dumps any `PassthroughLogger` logged messages to the console during its execution.
    public static func dump(
        _ body: () throws -> Void
    ) rethrows {
        try Self.GlobalConfiguration.$dumpToConsole.withValue(true) {
            try body()
        }
    }
    
    /// Executes the given asynchronous closure and dumps any `PassthroughLogger` logged messages to the console during its execution.
    public static func dump(
        _ body: () async throws -> Void
    ) async rethrows {
        try await Self.GlobalConfiguration.$dumpToConsole.withValue(true) {
            try await body()
        }
    }
}
