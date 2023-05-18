//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public enum POSIXFileAccessMode {
    case read
    case write
    case append
    case readUpdate
    case writeUpdate
    case appendUpdate
    
    public var rawValue: String {
        switch self {
            case .read:
                return "r"
            case .write:
                return "w"
            case .append:
                return "a"
            case .readUpdate:
                return "r+"
            case .writeUpdate:
                return "w+"
            case .appendUpdate:
                return "a+"
        }
    }
}
