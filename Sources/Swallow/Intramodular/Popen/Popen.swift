//
//  Popen.swift
//  Popen
//
//  Re-surface the popen() and pclose() functions
//  which can be ued to run shell commands on macOS
//  (and in the simulator). Open for read to process
//  output of command, write to send std input to the
//  command. The command is parsed and run by the shell.
//
//  Created by John Holdsworth on 24/02/2023.
//

import Foundation

@_silgen_name("popen")
public func popen(_: UnsafePointer<CChar>, _: UnsafePointer<CChar>) -> UnsafeMutablePointer<FILE>!
@_silgen_name("pclose")
public func pclose(_: UnsafeMutablePointer<FILE>?) -> Int32

public struct Popen {
    
    /// Alternate version of system() call returning stdout as a String.
    /// Can also return a string of errors only if there is a failure status.
    /// - Parameters:
    ///   - cmd: Command to execute
    ///   - errors: Switch between returning String on sucess or failure.
    /// - Returns: Output of command or errors on failure if errors is true.
    static public func system(_ cmd: String, errors: Bool = false) -> String? {
        let cmd = cmd + (errors ? " 2>&1" : "")
        guard let outfp = popen(cmd, "r") else {
            return "popen(\"\(cmd)\") failed."
        }
        let output = outfp.readAll()
        let failed = pclose(outfp) >> 8 != EXIT_SUCCESS
        return failed == errors ? output : nil
    }
}

// Basic extensions on UnsafeMutablePointer<FILE> to
// read the output of a shell command line by line.
// In conjuntion with popen() this is useful as
// Task/FileHandle does not provide a convenient
// means of reading just a line.
extension UnsafeMutablePointer:
    Sequence, IteratorProtocol where Pointee == FILE {
    public typealias Element = String

    public func next() -> String? {
        return readLine(strippingNewline: false)
    }

    public func readLine(strippingNewline: Bool = true) -> String? {
        var bufferSize = 10_000, offset = 0
        var buffer = [CChar](repeating: 0, count: bufferSize)

        while let line = fgets(&buffer[offset],
            Int32(buffer.count-offset), self) {
            offset += strlen(line)
            if buffer[offset-1] == UInt8(ascii: "\n") {
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
        defer { if close { _ = pclose(self) } }
        return reduce("", +)
    }

    @discardableResult
    public func print(_ line: String) -> Int32 {
        return fputs(line, self)
    }
}
