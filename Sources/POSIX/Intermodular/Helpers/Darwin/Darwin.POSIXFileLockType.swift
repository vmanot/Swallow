//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public enum POSIXFileLockType: RawRepresentable {
    public typealias RawValue = Int16
    
    case sharedOrRead
    case unlock
    case exclusiveOrWrite
    
    public var rawValue: RawValue {
        switch self {
            case .sharedOrRead:
                return .init(F_RDLCK)
            case .unlock:
                return .init(F_UNLCK)
            case .exclusiveOrWrite:
                return .init(F_WRLCK)
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
            case type(of: self).sharedOrRead.rawValue:
                self = .sharedOrRead
            case type(of: self).unlock.rawValue:
                self = .unlock
            case type(of: self).exclusiveOrWrite.rawValue:
                self = .exclusiveOrWrite
                
            default:
                return nil
        }
    }
}
