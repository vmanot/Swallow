//
// Copyright (c) Vatsal Manot
//

import Swift

// MARK: - Common Levels

extension LoggerProtocol {
    public func log(
        level: LogLevel,
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        emit(
            level: level,
            message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    public func log(
        level: LogLevel,
        ifPresent message: @autoclosure () -> LogMessage?,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        guard let message = message() else {
            return
        }

        log(
            level: level,
            message,
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    /// Logs already-rendered text without backend-specific interpolation.
    /// Backends may override this witness when constructing their message type
    /// from a dynamic string requires special handling.
    public func log(
        level: LogLevel,
        verbatim message: @autoclosure () -> String?,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        guard let message = message() else {
            return
        }

        log(
            level: level,
            LogMessage(stringLiteral: message),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    public func debug(
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .debug,
            message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    public func debug(
        ifPresent message: @autoclosure () -> LogMessage?,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .debug,
            ifPresent: message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    public func debug(
        verbatim message: @autoclosure () -> String?,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .debug,
            verbatim: message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    public func error(
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .error,
            message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    public func error(
        ifPresent message: @autoclosure () -> LogMessage?,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .error,
            ifPresent: message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    @discardableResult
    public func error(
        verbatim message: @autoclosure () -> String?,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) -> (any Error)? {
        guard let message = message() else {
            return nil
        }

        log(
            level: .error,
            verbatim: message,
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )

        return CustomStringError(describing: message)
    }

    @discardableResult
    public func error<E: Error>(
        _ error: @autoclosure () -> E,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) -> E {
        let error = error()

        log(
            level: .error,
            verbatim: String(describing: error),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )

        return error
    }

    @discardableResult
    public func error<E: Error>(
        ifPresent error: @autoclosure () -> E?,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) -> E? {
        guard let error = error() else {
            return nil
        }

        return self.error(error, metadata: metadata(), file: file, function: function, line: line)
    }
}

// MARK: - Client Levels

extension ClientLoggerProtocol {
    public func info(
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .info,
            message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    public func info(
        ifPresent message: @autoclosure () -> LogMessage?,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .info,
            ifPresent: message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    public func info(
        verbatim message: @autoclosure () -> String?,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .info,
            verbatim: message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    public func notice(
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .notice,
            message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    public func notice(
        ifPresent message: @autoclosure () -> LogMessage?,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .notice,
            ifPresent: message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    public func notice(
        verbatim message: @autoclosure () -> String?,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .notice,
            verbatim: message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    public func warning(
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .warning,
            message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    public func warning(
        ifPresent message: @autoclosure () -> LogMessage?,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .warning,
            ifPresent: message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    public func warning(
        verbatim message: @autoclosure () -> String?,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .warning,
            verbatim: message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    @discardableResult
    public func warning<E: Error>(
        _ error: @autoclosure () -> E,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) -> E {
        let error = error()
        log(
            level: .warning,
            verbatim: String(describing: error),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
        return error
    }

    @discardableResult
    public func warning<E: Error>(
        ifPresent error: @autoclosure () -> E?,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) -> E? {
        guard let error = error() else {
            return nil
        }

        return warning(error, metadata: metadata(), file: file, function: function, line: line)
    }

    public func fault(
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .fault,
            message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    public func fault(
        ifPresent message: @autoclosure () -> LogMessage?,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .fault,
            ifPresent: message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    public func fault(
        verbatim message: @autoclosure () -> String?,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .fault,
            verbatim: message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    public func critical(
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .critical,
            message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    public func critical(
        ifPresent message: @autoclosure () -> LogMessage?,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .critical,
            ifPresent: message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    public func critical(
        verbatim message: @autoclosure () -> String?,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .critical,
            verbatim: message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }
}

// MARK: - Server Levels

extension ServerLoggerProtocol {
    public func trace(
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .trace,
            message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    public func trace(
        ifPresent message: @autoclosure () -> LogMessage?,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .trace,
            ifPresent: message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    public func trace(
        verbatim message: @autoclosure () -> String?,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .trace,
            verbatim: message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    public func info(
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .info,
            message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    public func info(
        ifPresent message: @autoclosure () -> LogMessage?,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .info,
            ifPresent: message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    public func info(
        verbatim message: @autoclosure () -> String?,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .info,
            verbatim: message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    public func notice(
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .notice,
            message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    public func notice(
        ifPresent message: @autoclosure () -> LogMessage?,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .notice,
            ifPresent: message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    public func notice(
        verbatim message: @autoclosure () -> String?,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .notice,
            verbatim: message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    public func warning(
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .warning,
            message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    public func warning(
        ifPresent message: @autoclosure () -> LogMessage?,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .warning,
            ifPresent: message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    public func warning(
        verbatim message: @autoclosure () -> String?,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .warning,
            verbatim: message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    public func critical(
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .critical,
            message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    public func critical(
        ifPresent message: @autoclosure () -> LogMessage?,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .critical,
            ifPresent: message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }

    public func critical(
        verbatim message: @autoclosure () -> String?,
        metadata: @autoclosure () -> DiagnosticLogMetadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .critical,
            verbatim: message(),
            metadata: metadata(),
            file: file,
            function: function,
            line: line
        )
    }
}
