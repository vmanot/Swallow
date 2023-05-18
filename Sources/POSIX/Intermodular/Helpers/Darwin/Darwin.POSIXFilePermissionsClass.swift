//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public enum POSIXFilePermissionsClass: Hashable {
    case user
    case group
    case other
    case special
    case all
}
