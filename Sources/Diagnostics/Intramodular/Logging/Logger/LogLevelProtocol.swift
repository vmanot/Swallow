//
// Copyright (c) Vatsal Manot
//

#if canImport(os)
import os.log
#endif
#if canImport(OSLog)
import OSLog
#endif
import Swallow
import Swift

/// A type that represents a log-level.
public protocol LogLevelProtocol: StringConvertible {
    static var debug: Self { get }
    static var error: Self { get }
}

/// A type that represents a log-level suitable for client-side logging.
public protocol ClientLogLevelProtocol: LogLevelProtocol {
    static var undefined: Self { get }
    static var debug: Self { get }
    static var info: Self { get }
    static var notice: Self { get }
    static var warning: Self { get }
    static var error: Self { get }
    static var fault: Self { get }
    static var critical: Self { get }
}

/// A type that represents a log-level suitable for server-side logging.
public protocol ServerLogLevelProtocol: LogLevelProtocol {
    static var trace: Self { get }
    static var debug: Self { get }
    static var info: Self { get }
    static var notice: Self { get }
    static var warning: Self { get }
    static var error: Self { get }
    static var critical: Self { get }
}

// MARK: - Implemented Conformances

public enum AnyLogLevel: String, LogLevelProtocol {
    case undefined
    case trace
    case debug
    case info
    case notice
    case warning
    case error
    case fault
    case critical
    
    public var stringValue: String {
        rawValue
    }
}

/// A log-level type suitable for client applications.
public enum ClientLogLevel: String, ClientLogLevelProtocol, CustomStringConvertible {
    case undefined
    case debug
    case info
    case notice
    case warning
    case error
    case fault
    case critical
    
    public var stringValue: String {
        rawValue
    }
    
    public var description: String {
        stringValue
    }
}

/// A log-level type suitable for server applications.
public enum ServerLogLevel: String, ServerLogLevelProtocol {
    case trace
    case debug
    case info
    case notice
    case warning
    case error
    case critical
    
    public var stringValue: String {
        rawValue
    }
}

#if canImport(os)
extension os.OSLogType: Diagnostics.LogLevelProtocol {
    public var stringValue: String {
        switch self {
            case .debug:
                return "debug"
            case .info:
                return "info"
            case .error:
                return "error"
            case .fault:
                return "fault"
            default:
                return "unknown"
        }
    }
}
#endif

#if canImport(OSLog)
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension OSLogEntryLog.Level: Diagnostics.LogLevelProtocol {
    public var stringValue: String {
        switch self {
            case .undefined:
                return "undefined"
            case .debug:
                return "debug"
            case .info:
                return "info"
            case .notice:
                return "notice"
            case .error:
                return "error"
            case .fault:
                return "fault"
            @unknown default:
                return "unknown"
        }
    }
}
#endif
