//
// Copyright (c) Vatsal Manot
//

import Darwin
import Foundation
import SwiftUI

public enum Fortify {
    /// Protect a runLoop from crashes (your milage may vary)
    @_transparent
    public static func protect(
        runLoop: RunLoop,
        onError: @escaping (_ err: Error) -> Void
    ) {
        _Fortify.protect(runLoop: runLoop, onError: onError)
    }
    
    /// Execute the passed-in block assured in the knowledge
    /// any Swift exception will be converted into a throw.
    /// - Parameter block: block to protect execution of
    /// - Throws: Error protocol object often NSError
    /// - Returns: value if block returns value
    @_transparent
    public static func protect<T>(
        block: @Sendable () throws -> T
    ) throws -> T {
        return try _Fortify.protect(block: block)
    }
    
    /// Execute the passed-in block assured in the knowledge
    /// any Swift exception will be converted into a throw.
    /// - Parameter block: block to protect execution of
    /// - Throws: Error protocol object often NSError
    /// - Returns: value if block returns value
    @_transparent
    public static func protect<T>(
        block: () async throws -> T
    ) async throws -> T {
        runtimeIssue(.unimplemented)
        
        return try await block()
    }
    
    /// Escape from current execution context, rewind the stack
    /// and throw error from the last time protect was called.
    /// - Parameters:
    ///   - msg: A short message describing the error.
    @_transparent
    public static func escape(
        msg: String,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Never {
        _Fortify.escape(msg: msg, file: file, line: line)
    }
    
    /// Escape from current execution context, rewind the stack
    /// and throw error from the last time protect was called.
    /// - Parameter error: object conforming to Error.
    @_transparent
    public static func escape(
        withError error: Error
    ) -> Never {
        _Fortify.escape(withError: error)
    }
    
    @_transparent
    public static func stackTrace() -> String {
        return _Fortify.stackTrace()
    }
}

@usableFromInline
internal class _Fortify: ThreadLocal {
    static private var pthreadKey: pthread_key_t = 0
    
    override open class var threadKeyPointer: UnsafeMutablePointer<pthread_key_t> {
        return UnsafeMutablePointer(&pthreadKey)
    }
    
    private var stack = [jmp_buf]()
    public var error: Error?
    
    // Required as Swift assumes it has control of the stack
    static let disableExclusivityChecking: () = {
        if let stdlibHandle = dlopen(nil, Int32(RTLD_LAZY | RTLD_NOLOAD)),
           let disableExclusivity = dlsym(stdlibHandle, "_swift_disableExclusivityChecking") {
            disableExclusivity.assumingMemoryBound(to: Bool.self).pointee = true
        }
        else {
            NSLog("Could not disable exclusivity, failure likely...")
        }
    }()
    
    public static var signalsTrapped = [
        SIGILL: "SIGILL", // Force unwrap of nil etc.
        SIGABRT: "SIGABRT", // Bad cast 5.2
        SIGTRAP: "SIGTRAP", // Bad cast macOS 11
        SIGSEGV: "SIGSEGV", // Segmentation violation
        SIGBUS: "SIGBUS", // Bus error
    ]
    
    public static let installHandlersOnce: Void = {
        // Force unwrap of nil, bad cast etc.
        // macOS 11 abort() seems to send SIGTRAP
        for (signo, sigtxt) in signalsTrapped {
            _ = signal(signo, { (signo: Int32) in
                escape(msg: "Signal \(signalsTrapped[signo] ?? "#\(signo)")")
            })
        }
        
        // For Swift 5.3+, hook _assertionFailures
        if let handle = dlopen(nil, Int32(RTLD_LAZY)),
           let symbol = dlsym(handle, "_swift_disableExclusivityChecking") {
            symbol.assumingMemoryBound(to: Bool.self).pointee = true
        }
        else {
            NSLog("⚠️ Unable to hook _assertionFailure")
        }
        
        _ = disableExclusivityChecking
    }()
    
    /// Protect a runLoop from crashes (your milage may vary)
    @usableFromInline
    class func protect(
        runLoop: RunLoop,
        onError: @escaping (_ err: Error) -> Void
    ) {
        let _runLoop = _UncheckedSendable(runLoop)
        
        runLoop.perform {
            while true {
                do {
                    try protect {
                        _runLoop.wrappedValue.run()
                    }
                }
                catch {
                    onError(error)
                }
            }
        }
    }
    
    /// Execute the passed-in block assured in the knowledge
    /// any Swift exception will be converted into a throw.
    /// - Parameter block: block to protect execution of
    /// - Throws: Error protocol object often NSError
    /// - Returns: value if block returns value
    @usableFromInline
    class func protect<T>(
        block: @Sendable () throws -> T
    ) throws -> T {
        let local = threadLocal
        
        _ = installHandlersOnce
        
        empty_buf.withUnsafeBytes {
            let buf_ptr = $0.baseAddress!.assumingMemoryBound(to: jmp_buf.self)
            local.stack.append(buf_ptr.pointee)
        }
        
        defer {
            local.stack.removeLast()
        }
        
        if setjump(&local.stack[local.stack.count-1]) != 0 {
            throw local.error ?? NSError(domain: "Error not available", code: -1, userInfo: nil)
        }
        
        return try block()
    }
    
    /// Escape from current execution context, rewind the stack
    /// and throw error from the last time protect was called.
    /// - Parameters:
    ///   - msg: A short message describing the error.
    @usableFromInline
    class func escape(
        msg: String,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Never {
        let trace = "Program has trapped: \(msg) file: \(file), line: \(line)\nStack trace follows:\n\(stackTrace())"
        NSLog(trace)
        escape(withError: NSError(domain: "Fortify", code: -1, userInfo: [
            NSLocalizedDescriptionKey: trace, "file": file, "line": line
        ]))
    }
    
    /// Escape from current execution context, rewind the stack
    /// and throw error from the last time protect was called.
    /// - Parameter error: object conforming to Error.
    @usableFromInline
    class func escape(
        withError error: Error
    ) -> Never {
        let local = threadLocal
        local.error = error
        
        if local.stack.count == 0 {
            NSLog("Fortify.escape called without matching protect call: \(error)")
            NSLog("cancel/exit not available/implemented or crashes, parking thread")
            Thread.sleep(until: Date.distantFuture)
        }
        
        longjump(&local.stack[local.stack.count-1], 1)
        // control resumes at set_jump call returning 1
    }
    
    @usableFromInline
    class func stackTrace() -> String {
        var trace = ""
        for var caller in Thread.callStackSymbols {
            let symbolEnd = caller.lastIndex(of: " ") ?? caller.endIndex
            let symbolStart = caller.index(before: symbolEnd)
            let symbolRange = symbolStart..<symbolEnd
            if let symbol = caller[try: symbolRange].map({ String($0) }),
               let demangled = demangle(symbol: symbol) {
                caller.replaceSubrange(symbolRange, with: demangled)
            }
            trace += caller+"\n"
        }
        return trace
    }
    
    fileprivate class func demangle(symbol: UnsafePointer<Int8>) -> String? {
        if let demangledNamePtr = _stdlib_demangleImpl(
            mangledName: symbol,
            mangledNameLength: UInt(strlen(symbol)),
            outputBuffer: nil,
            outputBufferSize: nil,
            flags: 0
        ) {
            let demangledName = String(cString: demangledNamePtr)
            
            free(demangledNamePtr)
            
            return demangledName
        }
        
        return nil
    }
}

/// Abstract superclass to maintain ThreadLocal instances.
@usableFromInline
internal class ThreadLocal {
    static var keyLock = os_unfair_lock_s()
    
    public required init() {}
    
    open class var threadKeyPointer: UnsafeMutablePointer<pthread_key_t> {
        fatalError("Subclass responsibility to provide threadKey var")
    }
    
    public class var threadLocal: Self {
        let keyVar = threadKeyPointer
        os_unfair_lock_lock(&keyLock)
        if keyVar.pointee == 0 {
            let ret = pthread_key_create(keyVar, {
                Unmanaged<ThreadLocal>.fromOpaque($0).release()
            })
            if ret != 0 {
                fatalError("Could not pthread_key_create: \(String(cString: strerror(ret)))")
            }
        }
        os_unfair_lock_unlock(&keyLock)
        if let existing = pthread_getspecific(keyVar.pointee) {
            return Unmanaged<Self>.fromOpaque(existing).takeUnretainedValue()
        }
        else {
            let unmanaged = Unmanaged.passRetained(Self())
            let ret = pthread_setspecific(keyVar.pointee, unmanaged.toOpaque())
            if ret != 0 {
                fatalError("Could not pthread_setspecific: \(String(cString: strerror(ret)))")
            }
            return unmanaged.takeUnretainedValue()
        }
    }
}

@_silgen_name("swift_demangle")
public func _stdlib_demangleImpl(
    mangledName: UnsafePointer<CChar>?,
    mangledNameLength: UInt,
    outputBuffer: UnsafeMutablePointer<CChar>?,
    outputBufferSize: UnsafeMutablePointer<UInt>?,
    flags: UInt32
) -> UnsafeMutablePointer<CChar>?

internal func hook_assertionFailure(
    _ prefix: StaticString, _ message: StaticString,
    file: StaticString, line: UInt,
    flags: UInt32
) -> Never {
    Fortify.escape(msg: "\(message)", file: file, line: line)
}

internal func hook_assertionFailure(
    _ prefix: StaticString, _ message: String,
    file: StaticString, line: UInt,
    flags: UInt32
) -> Never {
    Fortify.escape(msg: message, file: file, line: line)
}

// MARK: - Internal

@_silgen_name("setjmp")
public func setjump(_: UnsafeMutablePointer<jmp_buf>) -> Int32
@_silgen_name("longjmp")
public func longjump(_: UnsafeMutablePointer<jmp_buf>, _: Int32) -> Never
private let empty_buf = [UInt8](repeating: 0, count: MemoryLayout<jmp_buf>.size)
