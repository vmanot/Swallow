//
// Copyright (c) Vatsal Manot
//

import Foundation
import os.log

@frozen
public struct XcodeRuntimeIssueLogger {
    /// Returns the shared default runtime issue logger with a generic category.
    public static let `default` = Self(category: "runtime-warning")
    
    @usableFromInline
    static let commonSubsystem = "com.apple.runtime-issues"
    
    @usableFromInline
    let log: OSLog
    @usableFromInline
    let callsiteCache = CallsiteCache()
    
    /// Initializes a custom runtime issue logger with a custom category.
    @_transparent
    public init(category: StaticString) {
        self.log = OSLog(subsystem: Self.commonSubsystem, category: String(_staticString: category))
    }
    
    /// Log a runtime issue to the console.
    ///
    /// When executed while attached to Xcode's debugger, this will have the additional effect
    /// of highlighting the issue and providing heads-up information regarding the issue.
    @_transparent
    public func raise(
        _ warningFormat: StaticString,
        file: StaticString = #file,
        line: UInt = #line,
        _ vaList: CVarArg...
    ) {
        guard _isDebugAssertConfiguration else {
            return
        }
        
        guard log.isEnabled(type: .fault), callsiteCache.shouldRaiseIssue(in: file, on: line) else {
            return
        }
        
        guard let handle = XcodeRuntimeIssueLogger.systemFrameworkHandle else {
            return RTI_RUNTIME_ISSUES_UNAVAILABLE()
        }
        
        os_log(.fault, dso: handle, log: log, warningFormat, vaList)
    }
}

extension XcodeRuntimeIssueLogger {
    @_transparent
    public func error(_ error: Error) {
        let errorDescription = String(describing: error)
        
        return runtimeIssue("%{public}@", errorDescription)
    }
}

// MARK: - API

@_transparent
public func runtimeIssue(
    _ warningFormat: StaticString,
    file: StaticString = #file,
    line: UInt = #line,
    _ arguments: CVarArg...
) {
    XcodeRuntimeIssueLogger.default.raise(
        warningFormat,
        file: file,
        line: line,
        arguments
    )
}

@_transparent
public func runtimeIssue(
    _ message: @autoclosure () -> String,
    file: StaticString = #file,
    line: UInt = #line
) {
    XcodeRuntimeIssueLogger.default.raise(
        "%{public}s",
        file: file,
        line: line,
        message()
    )
}

@_transparent
@discardableResult
public func runtimeIssue(
    _ error: Error,
    file: StaticString = #file,
    line: UInt = #line
) -> Error {
    runtimeIssue(String(describing: error))
    
    return error
}

@_transparent
@discardableResult
public func runtimeIssue(
    _ error: Never.Reason,
    file: StaticString = #file,
    line: UInt = #line
) -> Error {
    runtimeIssue(String(describing: error))
    
    return error
}

// MARK: - Auxiliary

extension XcodeRuntimeIssueLogger {
    public static let systemFrameworkHandle: UnsafeRawPointer? = {
        for i in 0..<_dyld_image_count() {
            // Technically any system framework would work, but this was inspired by SwiftUI's use
            // of runtime issues to report non-fatal but unexpected behavior.
            guard let name = _dyld_get_image_name(i).flatMap(String.init(utf8String:)), name.hasSuffix("/SwiftUI") else {
                continue
            }
            
            return UnsafeRawPointer(_dyld_get_image_header(i))
        }
        
        return nil
    }()
    
    public class CallsiteCache {
        private struct Invocation: Hashable {
            var file: HashedStaticString
            var line: UInt
        }
        
        private var lock = OSUnfairLock()
        private var invocations = Set<Invocation>()
        
        @usableFromInline
        init() {
            
        }
        
        /// Returns whether to raise a runtime issue in a file on a particular line.
        ///
        /// A notification of a runtime issue will only arise once, so only the first call will return true.
        public func shouldRaiseIssue(
            in file: StaticString,
            on line: UInt
        ) -> Bool {
            lock.withCriticalScope {
                return invocations.insert(Invocation(file: HashedStaticString(file), line: line)).inserted
            }
        }
    }
}

private var hasLoggedUnavailable = false

public func RTI_RUNTIME_ISSUES_UNAVAILABLE() {
    if hasLoggedUnavailable {
        return
    }
    
    os_log(.fault, "Warn only once: a runtime issue logging expectation was violated. Runtime issues will not be logged. Set a symbolic breakpoint on 'RTI_RUNTIME_ISSUES_UNAVAILABLE' to trace.")
    
    hasLoggedUnavailable = true
}

extension XcodeRuntimeIssueLogger {
    struct HashedStaticString: Hashable {
        private let base: StaticString
        
        init(_ base: StaticString) {
            self.base = base
        }
        
        @_transparent
        func hash(into hasher: inout Hasher) {
            base.withUTF8Buffer { buffer in
                hasher.combine(bytes: UnsafeRawBufferPointer(buffer))
            }
        }
        
        @_transparent
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.base.withUTF8Buffer { (lhs: UnsafeBufferPointer<UInt8>) in
                rhs.base.withUTF8Buffer { (rhs: UnsafeBufferPointer<UInt8>) in
                    zip(lhs, rhs).first(where: { $0.0 != $0.1 }) == nil
                }
            }
        }
    }
}
