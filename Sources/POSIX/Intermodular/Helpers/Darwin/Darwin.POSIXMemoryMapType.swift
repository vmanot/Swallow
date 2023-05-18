//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public enum POSIXMemoryMapType: RawRepresentable {
    public typealias RawValue = Int32

    case file
    case anonymous

    public var rawValue: RawValue {
        switch self {
        case .file:
            return MAP_FILE
        case .anonymous:
            return MAP_ANONYMOUS
        }
    }

    public init?(rawValue: RawValue) {
        switch rawValue {
        case MAP_FILE:
            self = .file
        case MAP_ANONYMOUS:
            self = .anonymous

        default:
            return nil
        }
    }
}

public enum POSIXMemoryMapAccessControl: Initiable, RawRepresentable {
    public typealias RawValue = Int32

    case shared
    case `private`

    public var rawValue: RawValue {
        switch self {
        case .shared:
            return MAP_SHARED
        case .private:
            return MAP_PRIVATE
        }
    }

    public init?(rawValue: RawValue) {
        switch rawValue {
        case MAP_SHARED:
            self = .shared
        case MAP_PRIVATE:
            self = .private

        default:
            return nil
        }
    }

    public init() {
        self = .shared
    }
}
