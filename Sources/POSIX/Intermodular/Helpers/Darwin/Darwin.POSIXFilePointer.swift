//
// Copyright (c) Vatsal Manot
//

import Darwin
import Foundation
import Swallow

public struct POSIXFilePointer: Wrapper {
    public typealias Value = UnsafeMutablePointer<FILE>
    
    public let value: Value

    public init(_ value: Value) {
        self.value = value
    }
}

extension POSIXFilePointer {
    public func getCharacters(count: Int32) throws -> NullTerminatedUTF8String {
        return .init(try fgets(.allocate(capacity: numericCast(count) + 1), numericCast(count), value).toPOSIXResult().get())
    }
}

extension POSIXFilePointer {
    public struct Position: Trivial {
        fileprivate var offset: Int64
        
        public init(offset: Int64) {
            self.offset = offset
        }
    }
    
    public func seek(to position: Position) throws {
        var position: fpos_t = position.offset
        
        _ = try withUnsafePointer(to: &position, { try fsetpos(value, $0).throwingAsPOSIXErrorIfNecessary() })
    }

    public func seek(to location: SeekLocation, offset: Int = 0) throws {
        try fseek(value, offset, location.rawValue).throwingAsPOSIXErrorIfNecessary()
    }

    public func position() throws -> Position {
        var pos: fpos_t = 0
        
        try fgetpos(value, &pos).throwingAsPOSIXErrorIfNecessary()
        
        return Position(offset: pos)
    }
}

extension POSIXFilePointer {
    public static func open(path: String, withMode mode: POSIXFileAccessMode) throws -> POSIXFilePointer {
        return try fopen(path, mode.rawValue).map(POSIXFilePointer.init).unwrapOrThrowLastPOSIXError()
    }
    
    public func close() throws {
        try fclose(value).throwingAsPOSIXErrorIfNecessary()
    }
    
    public func flush() throws {
        try fflush(value).throwingAsPOSIXErrorIfNecessary()
    }
}
