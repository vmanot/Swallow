//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public enum POSIXFilePermissionsMode: Hashable {
    case read
    case write
    case execute
    case setUserIDOnExecution
    case setGroupIDOnExecution
    case saveSwappedTextAfterUser
}
