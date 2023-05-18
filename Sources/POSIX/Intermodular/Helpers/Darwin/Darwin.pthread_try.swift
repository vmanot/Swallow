//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public func pthread_try(_ body: (() throws -> Int32)) throws {
    try body().throwingAsPOSIXErrorIfNecessary()
}

public func pthread_force_try(_ body: (() throws -> Int32)) {
    try! body().throwingAsPOSIXErrorIfNecessary()
}
 
