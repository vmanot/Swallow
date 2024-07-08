//
// Copyright (c) Vatsal Manot
//

import Swallow

/// A type that can log messages.
public protocol LoggerProtocol: Sendable {
    associatedtype LogLevel: LogLevelProtocol
    associatedtype LogMessage: LogMessageProtocol
    
    func log(
        level: LogLevel,
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> [String: Any]?,
        file: String,
        function: String,
        line: UInt
    )
}

// MARK: - Extensions

extension LoggerProtocol {
    @_disfavoredOverload
    @_transparent
    public func log(
        level: LogLevel,
        _ message: @autoclosure () -> String,
        metadata: @autoclosure () -> [String : Any]?,
        file: String,
        function: String,
        line: UInt
    ) {
        log(
            level: level,
            LogMessage(stringLiteral: message()),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }
    
    @_disfavoredOverload
    @_transparent
    public func debug(
        _ message:  @autoclosure () -> String,
        metadata: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        self.log(
            level: .debug,
            message(),
            metadata: metadata,
            file: file,
            function: function,
            line: line
        )
    }
    
    @_disfavoredOverload
    @_transparent
    @discardableResult
    public func error(
        _ error:  @autoclosure () -> String,
        metadata: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) -> any Swift.Error {
        let errorString: String = error()
        
        self.log(
            level: .error,
            errorString,
            metadata: metadata,
            file: file,
            function: function,
            line: line
        )
        
        return CustomStringError(describing: errorString)
    }

    @_disfavoredOverload
    @_transparent
    @discardableResult
    public func error(
        _ error:  @autoclosure () -> Error,
        metadata: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) -> any Swift.Error {
        let errorString: String = String(describing: error())

        self.log(
            level: .error,
            errorString,
            metadata: metadata,
            file: file,
            function: function,
            line: line
        )
        
        return CustomStringError(describing: errorString)
    }
}

extension LoggerProtocol where LogLevel: ClientLogLevelProtocol {
    @_transparent
    public func info(
        _ message: @autoclosure () -> String,
        metadata: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .info,
            message(),
            metadata: metadata,
            file: file,
            function: function,
            line: line
        )
    }
    
    @_transparent
    public func warning(
        _ warning:  @autoclosure () -> String,
        metadata: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .warning,
            warning(),
            metadata: metadata,
            file: file,
            function: function,
            line: line
        )
    }
    
    @_transparent
    public func warning(
        _ warning:  @autoclosure () -> Error,
        metadata: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .warning,
            String(describing: warning()),
            metadata: metadata,
            file: file,
            function: function,
            line: line
        )
    }
}
