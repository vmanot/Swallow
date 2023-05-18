//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public enum POSIXMemoryPageLocation: Int32, Hashable, Initiable {
    case inCore
    case referencedByCaller
    case modifiedByCaller
    case referencedByOther
    case modifiedByOther

    public init() {
        self = .inCore
    }
}

extension POSIXMemoryPageLocation {
    public typealias RawValue = Int32

    public var rawValue: RawValue {
        switch self {
        case .inCore:
            return MINCORE_INCORE
        case .referencedByCaller:
            return MINCORE_REFERENCED
        case .modifiedByCaller:
            return MINCORE_MODIFIED
        case .referencedByOther:
            return MINCORE_REFERENCED_OTHER
        case .modifiedByOther:
            return MINCORE_MODIFIED_OTHER
        }
    }

    public init?(rawValue: RawValue) {
        switch rawValue {
        case type(of: self).inCore.rawValue:
            self = .inCore
        case type(of: self).referencedByCaller.rawValue:
            self = .referencedByCaller
        case type(of: self).modifiedByCaller.rawValue:
            self = .modifiedByCaller
        case type(of: self).referencedByOther.rawValue:
            self = .referencedByOther
        case type(of: self).modifiedByOther.rawValue:
            self = .modifiedByOther

        default:
            return nil
        }
    }
}
