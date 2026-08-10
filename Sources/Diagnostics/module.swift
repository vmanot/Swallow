//
// Copyright (c) Vatsal Manot
//

@_exported import ErrorX
@_exported import Swallow
import SwallowMacrosClient

#if DEBUG
let _isDebugBuild = true
#else
let _isDebugBuild = false
#endif

public enum _module {

}

@available(*, deprecated, renamed: "DiagnosticLoggingEnvironment")
public typealias _DiagnosticLoggingEnvironment = DiagnosticLoggingEnvironment

@available(*, deprecated, renamed: "GlobalDiagnosticLoggingEnvironment")
public typealias _GlobalDiagnosticLoggingEnvironment = GlobalDiagnosticLoggingEnvironment

extension DiagnosticLoggingEnvironment {
    @available(*, deprecated, renamed: "withValue(_:operation:)")
    public static func withEnvironment<R>(
        _ environment: Self,
        operation: () throws -> R
    ) rethrows -> R {
        try withValue(environment, operation: operation)
    }

    @available(*, deprecated, renamed: "withValue(_:operation:)")
    public static func withEnvironment<R>(
        _ environment: Self,
        operation: () async throws -> R
    ) async rethrows -> R {
        try await withValue(environment, operation: operation)
    }
}

extension LoggerProtocol {
    @_disfavoredOverload
    @available(
        *,
        deprecated,
        message:
            "Use log(level:verbatim:metadata:file:function:line:) for an already-rendered String."
    )
    public func log(
        level: LogLevel,
        _ message: @autoclosure () -> String,
        metadata: @autoclosure () -> [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: level,
            verbatim: message(),
            metadata: metadata().map(DiagnosticLogMetadata.init(describingLegacyMetadata:)),
            file: file,
            function: function,
            line: line
        )
    }

    @_disfavoredOverload
    @available(
        *,
        deprecated,
        message: "Use debug(verbatim:metadata:file:function:line:) for an already-rendered String."
    )
    public func debug(
        _ message: @autoclosure () -> String,
        metadata: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        debug(
            verbatim: message(),
            metadata: metadata.map(DiagnosticLogMetadata.init(describingLegacyMetadata:)),
            file: file,
            function: function,
            line: line
        )
    }

    @_disfavoredOverload
    @discardableResult
    @available(
        *,
        deprecated,
        message: "Use error(verbatim:metadata:file:function:line:) for an already-rendered String."
    )
    public func error(
        _ message: @autoclosure () -> String,
        metadata: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) -> any Swift.Error {
        error(
            verbatim: message(),
            metadata: metadata.map(DiagnosticLogMetadata.init(describingLegacyMetadata:)),
            file: file,
            function: function,
            line: line
        )!
    }

    @_disfavoredOverload
    @discardableResult
    @available(
        *,
        deprecated,
        message: "Use error(_:metadata:file:function:line:) with DiagnosticLogMetadata."
    )
    public func error<E: Error>(
        _ error: @autoclosure () -> E,
        metadata: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) -> E {
        self.error(
            error(),
            metadata: metadata.map(DiagnosticLogMetadata.init(describingLegacyMetadata:)),
            file: file,
            function: function,
            line: line
        )
    }
}

extension LoggerProtocol where LogLevel: ClientLogLevelProtocol {
    @_disfavoredOverload
    @available(
        *,
        deprecated,
        message: "Use info(verbatim:metadata:file:function:line:) for an already-rendered String."
    )
    public func info(
        _ message: @autoclosure () -> String,
        metadata: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .info,
            verbatim: message(),
            metadata: metadata.map(DiagnosticLogMetadata.init(describingLegacyMetadata:)),
            file: file,
            function: function,
            line: line
        )
    }

    @_disfavoredOverload
    @available(
        *,
        deprecated,
        message: "Use notice(verbatim:metadata:file:function:line:) for an already-rendered String."
    )
    public func notice(
        _ message: @autoclosure () -> String,
        metadata: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .notice,
            verbatim: message(),
            metadata: metadata.map(DiagnosticLogMetadata.init(describingLegacyMetadata:)),
            file: file,
            function: function,
            line: line
        )
    }

    @_disfavoredOverload
    @available(
        *,
        deprecated,
        message:
            "Use warning(verbatim:metadata:file:function:line:) for an already-rendered String."
    )
    public func warning(
        _ message: @autoclosure () -> String,
        metadata: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .warning,
            verbatim: message(),
            metadata: metadata.map(DiagnosticLogMetadata.init(describingLegacyMetadata:)),
            file: file,
            function: function,
            line: line
        )
    }

    @_disfavoredOverload
    @discardableResult
    @available(
        *,
        deprecated,
        message: "Use warning(_:metadata:file:function:line:) with DiagnosticLogMetadata."
    )
    public func warning<E: Error>(
        _ error: @autoclosure () -> E,
        metadata: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) -> E {
        let error = error()

        log(
            level: .warning,
            verbatim: String(describing: error),
            metadata: metadata.map(DiagnosticLogMetadata.init(describingLegacyMetadata:)),
            file: file,
            function: function,
            line: line
        )

        return error
    }

    @_disfavoredOverload
    @available(
        *,
        deprecated,
        message: "Use fault(verbatim:metadata:file:function:line:) for an already-rendered String."
    )
    public func fault(
        _ message: @autoclosure () -> String,
        metadata: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .fault,
            verbatim: message(),
            metadata: metadata.map(DiagnosticLogMetadata.init(describingLegacyMetadata:)),
            file: file,
            function: function,
            line: line
        )
    }

    @_disfavoredOverload
    @available(
        *,
        deprecated,
        message:
            "Use critical(verbatim:metadata:file:function:line:) for an already-rendered String."
    )
    public func critical(
        _ message: @autoclosure () -> String,
        metadata: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .critical,
            verbatim: message(),
            metadata: metadata.map(DiagnosticLogMetadata.init(describingLegacyMetadata:)),
            file: file,
            function: function,
            line: line
        )
    }
}

extension LoggerProtocol where LogLevel: ServerLogLevelProtocol {
    @_disfavoredOverload
    @available(
        *,
        deprecated,
        message: "Use trace(verbatim:metadata:file:function:line:) for an already-rendered String."
    )
    public func trace(
        _ message: @autoclosure () -> String,
        metadata: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .trace,
            verbatim: message(),
            metadata: metadata.map(DiagnosticLogMetadata.init(describingLegacyMetadata:)),
            file: file,
            function: function,
            line: line
        )
    }

    @_disfavoredOverload
    @available(
        *,
        deprecated,
        message: "Use info(verbatim:metadata:file:function:line:) for an already-rendered String."
    )
    public func info(
        _ message: @autoclosure () -> String,
        metadata: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .info,
            verbatim: message(),
            metadata: metadata.map(DiagnosticLogMetadata.init(describingLegacyMetadata:)),
            file: file,
            function: function,
            line: line
        )
    }

    @_disfavoredOverload
    @available(
        *,
        deprecated,
        message: "Use notice(verbatim:metadata:file:function:line:) for an already-rendered String."
    )
    public func notice(
        _ message: @autoclosure () -> String,
        metadata: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .notice,
            verbatim: message(),
            metadata: metadata.map(DiagnosticLogMetadata.init(describingLegacyMetadata:)),
            file: file,
            function: function,
            line: line
        )
    }

    @_disfavoredOverload
    @available(
        *,
        deprecated,
        message:
            "Use warning(verbatim:metadata:file:function:line:) for an already-rendered String."
    )
    public func warning(
        _ message: @autoclosure () -> String,
        metadata: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .warning,
            verbatim: message(),
            metadata: metadata.map(DiagnosticLogMetadata.init(describingLegacyMetadata:)),
            file: file,
            function: function,
            line: line
        )
    }

    @_disfavoredOverload
    @available(
        *,
        deprecated,
        message:
            "Use critical(verbatim:metadata:file:function:line:) for an already-rendered String."
    )
    public func critical(
        _ message: @autoclosure () -> String,
        metadata: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .critical,
            verbatim: message(),
            metadata: metadata.map(DiagnosticLogMetadata.init(describingLegacyMetadata:)),
            file: file,
            function: function,
            line: line
        )
    }
}
