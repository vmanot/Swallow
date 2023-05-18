//
// Copyright (c) Vatsal Manot
//

#if canImport(Logging)
import Logging
import os
import Swift

@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
public class OSLogHandler: SwiftLogLogHandler {
    public var metadata: [String: SwiftLogLogger.Metadata.Value] = [:]
    public var logLevel: SwiftLogLogger.Level = .debug
    
    private let logger: os.Logger
    
    public init(label: String) {
        let labelComponents = label.components(separatedBy: ".")
        
        let subsystem = labelComponents.prefix(3).joined(separator: ".")
        let category = labelComponents.dropFirst(3).joined(separator: ".")
        
        self.logger = .init(subsystem: subsystem, category: category)
    }
    
    public subscript(metadataKey key: String) -> SwiftLogLogger.Metadata.Value? {
        get {
            metadata[key]
        } set {
            metadata[key] = newValue
        }
    }
    
    public func log(
        level: SwiftLogLogger.Level,
        message: SwiftLogLogger.Message,
        metadata: SwiftLogLogger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        logger.log(level: .init(level), "\(message.description, privacy: .sensitive)")
    }
    
    public func log(
        level: SwiftLogLogger.Level,
        message: SwiftLogLogger.Message,
        metadata: SwiftLogLogger.Metadata?,
        file: String,
        function: String,
        line: UInt
    ) {
        logger.log(level: .init(level), "\(message.description)")
    }
}

// MARK: - Auxiliary

extension OSLogType {
    fileprivate init(_ level: SwiftLogLogger.Level) {
        switch level {
            case .trace:
                self = .debug
            case .debug:
                self = .debug
            case .info:
                self = .info
            case .notice:
                self = .info
            case .warning:
                self = .error
            case .error:
                self = .error
            case .critical:
                self = .fault
        }
    }
}
#endif
