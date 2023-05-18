//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public struct POSIXFileStatus: Wrapper {
    public typealias Value = stat
    
    public let value: Value

    public init(_ value: Value) {
        self.value = value
    }
}

extension POSIXFileStatus {
    public var inode: POSIXINode {
        return .init(value.st_ino)
    }
    
    public var size: Int64 {
        return value.st_size
    }
    
    public var permissions: POSIXFilePermissions {
        return .init(rawValue: value.st_mode)
    }
}

// MARK: - Helpers

extension POSIXIOResourceDescriptor {
    public func getFileStatus() throws -> POSIXFileStatus {
        var resultValue: stat = .init()
        
        try fstat(rawValue, &resultValue).throwingAsPOSIXErrorIfNecessary()
        
        return .init(resultValue)
    }
}
