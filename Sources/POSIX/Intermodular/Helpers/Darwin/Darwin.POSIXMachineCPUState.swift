//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public enum POSIXMachineCPUState: Int32 {
    case user
    case system
    case idle
    case nice
    case maximum
}

extension POSIXMachineCPUState {
    public typealias RawValue = Int32
    
    public var rawValue: RawValue {
        switch self {
            case .user:
                return CPU_STATE_USER
            case .system:
                return CPU_STATE_SYSTEM
            case .idle:
                return CPU_STATE_IDLE
            case .nice:
                return CPU_STATE_NICE
            case .maximum:
                return CPU_STATE_MAX
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
            case type(of: self).user.rawValue:
                self = .user
            case type(of: self).system.rawValue:
                self = .system
            case type(of: self).idle.rawValue:
                self = .idle
            case type(of: self).nice.rawValue:
                self = .nice
            case type(of: self).maximum.rawValue:
                self = .maximum

            default:
                return nil
        }
    }
}
