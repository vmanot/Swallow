//
// Copyright (c) Vatsal Manot
//

import Swift

#if canImport(OSLog)
import os
import OSLog

protocol OSLoggerProtocol {
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    func log(level: OSLogType, _ message: OSLogMessage)
    
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    func debug(_ message: OSLogMessage)
    
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    func info(_ message: OSLogMessage)
    
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    func notice(_ message: OSLogMessage)
    
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    func warning(_ message: OSLogMessage)
    
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    func error(_ message: OSLogMessage)
    
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    func fault(_ message: OSLogMessage)
    
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    func critical(_ message: OSLogMessage)
}

@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
extension OSLogger: LoggerProtocol, OSLoggerProtocol, @unchecked Sendable {
    public typealias LogLevel = OSLogType
    public typealias LogMessage = OSLogMessage
    
    public func log(
        level: LogLevel,
        _ message: @autoclosure () -> LogMessage,
        metadata: @autoclosure () -> [String : Any]?,
        file: String,
        function: String,
        line: UInt
    ) {
        (self as OSLoggerProtocol).log(level: level, message())
    }
    
    func _log(
        level: ClientLogLevel,
        _ message: @autoclosure () -> String,
        metadata: @autoclosure () -> [String : Any]? = nil
    ) {
        let _message = message()

        switch level {
            case .undefined:
                self.log(level: .default, "\(_message)")
            case .debug:
                self.debug("\(_message)")
            case .info:
                self.info("\(_message)")
            case .notice:
                self.notice("\(_message)")
            case .warning:
                self.warning("\(_message)")
            case .error:
                self.error("\(_message)")
            case .fault:
                self.fault("\(_message)")
            case .critical:
                self.critical("\(_message)")
        }
    }
}
#endif
