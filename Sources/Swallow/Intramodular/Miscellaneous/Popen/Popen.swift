//
// Copyright (c) Vatsal Manot
//

import Darwin
import Foundation
import Swift

@_silgen_name("popen")
public func popen(
    _: UnsafePointer<CChar>,
    _: UnsafePointer<CChar>
) -> UnsafeMutablePointer<FILE>!

@_silgen_name("pclose")
public func pclose(
    _: UnsafeMutablePointer<FILE>?
) -> CInt

public protocol FILEStream {
    var fileStream: UnsafeMutablePointer<FILE> { get }
}

open class Popen: FILEStream, Sequence, IteratorProtocol {
    public struct TerminationError: Swift.Error {
        
    }
    
    static var openFILEStreams = 0
    
    public static var shellCommand = "/bin/zsh"
    
    open var fileStream: UnsafeMutablePointer<FILE>
    open var exitStatus: CInt?

    /// Execute a shell command
    /// - Parameters:
    ///   - cmd: Command to execute
    ///   - shell: Shell to use for the command.
    /// - Returns: true if command exited without error.
    open class func shell(
        cmd: String,
        shell: String = shellCommand
    ) -> Bool {
        guard let stdin = Popen(cmd: shell, mode: .write) else {
            return false
        }
        
        stdin.print(cmd)
        
        return stdin.terminatedOK()
    }
    
    /// Alternate version of system() call returning stdout as a String.
    /// Can also return a string of errors only if there is a failure status.
    /// - Parameters:
    ///   - cmd: Command to execute
    ///   - errors: Switch between returning String on sucess or failure.
    /// - Returns: Output of command or errors on failure if errors is true.
    open class func system(
        _ cmd: String,
        errors: Bool = false
    ) throws -> String? {
        let cmd = cmd + (errors ? " 2>&1" : "")
        
        guard let outfp = Popen(cmd: cmd) else {
            runtimeIssue(cmd)
            
            throw TerminationError()
        }
        
        let output: String = outfp.readAll()
   
        return outfp.terminatedOK() != errors ? output : nil
    }
        
    public init?(
        cmd: String,
        mode: Fopen.FILEMode = .read
    ) {
        guard let handle = popen(cmd, mode.mode) else {
            return nil
        }
        
        fileStream = handle
        
        Self.openFILEStreams += 1
    }
    
    open func terminatedOK() -> Bool {
        exitStatus = pclose(fileStream)
        
        return exitStatus! >> 8 == EXIT_SUCCESS
    }
    
    deinit {
        if exitStatus == nil {
            _ = terminatedOK()
        }
        
        Self.openFILEStreams -= 1
    }
}

extension Swift.UnsafeMutablePointer: Swallow.FILEStream, Swift.Sequence, Swift.IteratorProtocol where Pointee == FILE {
    public typealias Element = String
    public var fileStream: Self { return self }
}

// Basic extensions on UnsafeMutablePointer<FILE>
// and Popen to read the output of a shell command
// line by line. In conjuntion with popen() this is
// useful as Task/FileHandle does not provide a
// convenient way of reading an individual line.
extension FILEStream {
    public func next() -> String? {
        return readLine() // ** No longer includes tailing newline **
    }
    
    public func readLine(strippingNewline: Bool = true) -> String? {
        var bufferSize = 10_000, offset = 0
        var buffer = [CChar](repeating: 0, count: bufferSize)
        
        while let line = fgets(&buffer[offset],
                               CInt(buffer.count-offset), fileStream) {
            offset += strlen(line+offset)
            if offset > 0 && buffer[offset-1] == UInt8(ascii: "\n") {
                if strippingNewline {
                    buffer[offset-1] = 0
                }
                return String(cString: buffer)
            }
            
            bufferSize *= 2
            var grown = [CChar](repeating: 0, count: bufferSize)
            strcpy(&grown, buffer)
            buffer = grown
        }
        
        return offset > 0 ? String(cString: buffer) : nil
    }
    
    public func readAll(close: Bool = false) -> String {
        defer {
            if close {
                _ = pclose(fileStream)
            }
        }
        
        var out = ""
        
        while let line = readLine(strippingNewline: false) {
            out += line
        }
        
        return out
    }
    
    @discardableResult
    public func print(
        _ items: Any...,
        separator: String = " ",
        terminator: String = "\n"
    ) -> CInt {
        fputs(items
            .map { "\($0)" }
            .joined(separator: separator) + terminator, fileStream)
    }
    
    public func write(data: Data) -> Int {
        withUnsafeBytes(of: data) { buffer in
            fwrite(buffer.baseAddress, 1, buffer.count, fileStream)
        }
    }
    
    @discardableResult
    public func flush() -> CInt {
        fflush(fileStream)
    }
}
