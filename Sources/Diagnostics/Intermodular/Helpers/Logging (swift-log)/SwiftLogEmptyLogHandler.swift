//
// Copyright (c) Vatsal Manot
//

#if canImport(Logging)
import Logging
import Swift

public class SwiftLogEmptyLogHandler: LogHandler {
    public var metadata: [String: Logger.Metadata.Value] = [:]
    public var logLevel: Logger.Level = .debug
    
    public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get {
            metadata[key]
        } set {
            metadata[key] = newValue
        }
    }
    
    public func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        
    }
    
    public func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        file: String,
        function: String,
        line: UInt
    ) {
        
    }
}
#endif
