//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public struct POSIXDirectoryPointer: Wrapper {
    public typealias Value = UnsafeMutablePointer<DIR>
    
    public let value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
}

// MARK: - Extensions

extension POSIXDirectoryPointer {
    public init(path: String) throws {
        self.init(try (opendir(path) as Optional).toPOSIXResult().get())
    }
}

extension POSIXDirectoryPointer {
    public var descriptor: POSIXIOResourceDescriptor {
        return .init(rawValue: dirfd(value))
    }
}

extension POSIXDirectoryPointer {
    public var offsetInDirectory: Int {
        return telldir(value)
    }
    
    public func seek(toDirectoryOffset offset: Int) {
        seekdir(value, offset)
    }

    public func seekToStartOfDirectory() {
        rewinddir(value)
    }
}

extension POSIXDirectoryPointer {
    public func close() {
        closedir(value)
    }
}
