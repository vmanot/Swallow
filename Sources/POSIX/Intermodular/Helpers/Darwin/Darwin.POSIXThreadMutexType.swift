//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public enum POSIXThreadMutexType: Initiable {
    case normal
    case errorCheck
    case recursive
    case `default`
    
    public init() {
        self = .default
    }
}

extension POSIXThreadMutexType: Hashable, RawRepresentable {
    public typealias RawValue = Int32
    
    public var rawValue: RawValue {
        switch self {
            case .normal:
                return Darwin.PTHREAD_MUTEX_NORMAL
            case .errorCheck:
                return Darwin.PTHREAD_MUTEX_ERRORCHECK
            case .recursive:
                return Darwin.PTHREAD_MUTEX_RECURSIVE
            case .default:
                return Darwin.PTHREAD_MUTEX_DEFAULT
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
            case type(of: self).normal.rawValue:
                self = .normal
            case type(of: self).errorCheck.rawValue:
                self = .errorCheck
            case type(of: self).recursive.rawValue:
                self = .recursive
            case type(of: self).default.rawValue:
                self = .default

            default:
                return nil
        }
    }
}
