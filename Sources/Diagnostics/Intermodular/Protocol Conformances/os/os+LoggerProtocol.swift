//
// Copyright (c) Vatsal Manot
//

import Swift

#if canImport(OSLog)
import os
import OSLog

@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
protocol OSLoggerProtocol {
    func log(level: OSLogType, _ message: OSLogMessage)
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
}
#endif
