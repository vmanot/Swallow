//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public struct POSIXFileLock: Wrapper {
    public typealias Value = flock
    
    public var value: Value

    public init(_ value: Value) {
        self.value = value
    }
}

extension POSIXFileLock {
    public var startOffset: Int64 {
        get {
            return value.l_start
        } set {
            value.l_start = newValue
        }
    }

    public var length: Int64 {
        get {
            return value.l_len
        } set {
            value.l_len = newValue
        }
    }

    public var owner: POSIXProcessIdentifier {
        get {
            return .init(value.l_pid)
        } set {
            value.l_pid = newValue.value
        }
    }

    public var type: POSIXFileLockType {
        get {
            return POSIXFileLockType(rawValue: .init(value.l_type))!
        } set {
            value.l_type = .init(newValue.rawValue)
        }
    }

    public var whence: POSIXFilePointer.SeekLocation {
        get {
            return POSIXFilePointer.SeekLocation(rawValue: numericCast(value.l_whence))!
        } set {
            value.l_whence = numericCast(newValue.rawValue)
        }
    }
    
    public init(startOffset: Int64, length: Int64, owner: POSIXProcessIdentifier = .current, type: POSIXFileLockType, whence: POSIXFilePointer.SeekLocation = .none) {
        self.init(.init())
        
        self.startOffset = startOffset
        self.length = length
        self.owner = owner
        self.type = type
        self.whence = whence
    }
}
