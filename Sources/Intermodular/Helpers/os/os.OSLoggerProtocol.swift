//
// Copyright (c) Vatsal Manot
//

import Foundation
import os
import Swift

public protocol OSLoggerProtocol {
    static func debug(_ message: StaticString, _ args: CVarArg...)
    static func debug(systemLog: OSSystemLog, _ message: StaticString, _ args: CVarArg...)

    static func info(_ message: StaticString, _ args: CVarArg...)
    static func info(systemLog: OSSystemLog, _ message: StaticString, _ args: CVarArg...)

    static func error(_ message: StaticString, _ args: CVarArg...)
    static func error(systemLog: OSSystemLog, _ message: StaticString, _ args: CVarArg...)

    static func fault(_ message: StaticString, _ args: CVarArg...)
    static func fault(systemLog: OSSystemLog, _ message: StaticString, _ args: CVarArg...)
}

// MARK: - Concrete Implementations -

public class OSDefaultLogger: OSLoggerProtocol {
    private class func log(_ level: OSLogType = .default, _ message: StaticString, _ args: CVarArg...) {
        os_log(message, type: level, args)
    }

    private class func log(systemLog: OSSystemLog, level: OSLogType = .default, message: StaticString, args: CVarArg...) {
        os_log(level, log: systemLog.toOSLog(), message, args)
    }

    public class func debug(_ message: StaticString, _ args: CVarArg...) {
        log(.debug, message, args)
    }

    public class func debug(systemLog: OSSystemLog, _ message: StaticString, _ args: CVarArg...) {
        log(systemLog: systemLog, level: .debug, message: message, args: args)
    }

    public class func info(_ message: StaticString, _ args: CVarArg...) {
        log(.default, message, args)
    }

    public class func info(systemLog: OSSystemLog, _ message: StaticString, _ args: CVarArg...) {
        log(systemLog: systemLog, level: .info, message: message, args: args)
    }

    public class func error(_ message: StaticString, _ args: CVarArg...) {
        log(.error, message, args)
    }

    public class func error(systemLog: OSSystemLog, _ message: StaticString, _ args: CVarArg...) {
        log(systemLog: systemLog, level: .error, message: message, args: args)
    }

    public class func fault(_ message: StaticString, _ args: CVarArg...) {
        log(.fault, message, args)
    }

    public class func fault(systemLog: OSSystemLog, _ message: StaticString, _ args: CVarArg...) {
        log(systemLog: systemLog, level: .fault, message: message, args: args)
    }
}
