//
// Copyright (c) Vatsal Manot
//

import Darwin
import Foundation
import Swallow

public struct POSIXIOResourceDescriptor: RawRepresentable {
    public typealias RawValue = CInt
    
    public internal(set) var rawValue: RawValue
    
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

extension POSIXIOResourceDescriptor {
    public func lock() {
        flock(rawValue, LOCK_EX)
    }

    public func unlock() {
        flock(rawValue, LOCK_UN)
    }
}

extension POSIXIOResourceDescriptor {
    public var isOpen: Bool {
        return !isClosed
    }
    
    public var isClosed: Bool {
        return (fcntl(rawValue, F_GETFL) == -1) ? (errno == EBADF) : false
    }

    public func close() throws {
        try Darwin.close(rawValue).throwingAsPOSIXErrorIfNecessary()
    }
}

extension POSIXIOResourceDescriptor {
    public func resolveFilePath() throws -> String {
        var buffer = Data(count: Int(MAXPATHLEN))
        _ = try buffer.withUnsafeMutableBytes { buffer in
            try fcntl(rawValue, F_GETPATH, buffer.baseAddress!)
                .throwingAsPOSIXErrorIfNecessary()
        }
        return buffer.withUnsafeBytes {
            String(cString: $0.baseAddress!.assumingMemoryBound(to: CChar.self))
        }
    }
}

// MARK: - Extensions 

extension POSIXIOResourceDescriptor {
    public func map(length: Int, protection: POSIXMemoryMapProtection, accessControl: POSIXMemoryMapAccessControl = .private, flags: POSIXMemoryMapOtherFlags = [], offset: Int64 = 0) throws -> POSIXMemoryMap {
        return try .init(length: length, protection: protection, accessControl: accessControl, flags: flags, descriptor: self, offset: offset)
    }
}

// MARK: - Conformances

extension POSIXIOResourceDescriptor: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: RawValue) {
        self.init(rawValue: value)
    }
}

// MARK: - Helpers

extension FileHandle {
    public var rawValue: POSIXIOResourceDescriptor {
        return .init(rawValue: fileDescriptor)
    }
}
