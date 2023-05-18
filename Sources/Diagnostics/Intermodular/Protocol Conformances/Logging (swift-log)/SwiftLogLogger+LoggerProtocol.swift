//
// Copyright (c) Vatsal Manot
//

import Swift

#if canImport(Logging)
import Logging

extension SwiftLogLogger: LoggerProtocol, @unchecked Sendable {
    public typealias LogLevel = SwiftLogLogger.Level
    public typealias LogMessage = SwiftLogLogger.Message
    
    public func log(
        level: SwiftLogLogger.Level,
        _ message: @autoclosure () -> SwiftLogLogger.Message,
        metadata: @autoclosure () -> [String : Any]?,
        file: String,
        function: String,
        line: UInt
    ) {
        log(
            level: level,
            message(),
            metadata: metadata()?.mapValues({ Logger.MetadataValue(from: $0) }),
            source: nil,
            file: file,
            function: function,
            line: line
        )
    }
}
#endif
