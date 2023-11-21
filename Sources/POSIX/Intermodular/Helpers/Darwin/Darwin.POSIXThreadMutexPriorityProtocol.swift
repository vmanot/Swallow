//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

@frozen
public enum POSIXThreadMutexPriorityProtocol: Int32, Initiable {
    case none
    case inheriting
    case protecting
    
    public init() {
        self = .none
    }
}

extension POSIXThreadMutexPriorityProtocol: Hashable {
    public typealias RawValue = Int32
    
    public var rawValue: RawValue {
        @inlinable get {
            switch self {
                case .none:
                    return PTHREAD_PRIO_NONE
                case .inheriting:
                    return PTHREAD_PRIO_INHERIT
                case .protecting:
                    return PTHREAD_PRIO_PROTECT
            }
        }
    }
    
    @inlinable
    public init?(rawValue: RawValue) {
        switch rawValue {
            case POSIXThreadMutexPriorityProtocol.none.rawValue:
                self = .none
            case POSIXThreadMutexPriorityProtocol.inheriting.rawValue:
                self = .inheriting
            case POSIXThreadMutexPriorityProtocol.protecting.rawValue:
                self = .protecting
                
            default:
                return nil
        }
    }
}
