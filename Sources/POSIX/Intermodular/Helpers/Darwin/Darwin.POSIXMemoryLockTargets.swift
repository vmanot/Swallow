//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public struct POSIXMemoryLockTarget: RawRepresentable {
    public typealias RawValue = Int32
    
    public let rawValue: RawValue
    
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

extension POSIXMemoryLockTarget: OptionSet {
    public static let currentPages = with(rawValue: MCL_CURRENT)
    public static let futurePages = with(rawValue: MCL_FUTURE)
}

// MARK: - Helpers

extension BufferPointer {
    public func lockRawMemoryIntoRAM() throws {
        try mlock(unsafeRawPointerRepresentation, .init(count) * MemoryLayout<Element>.size).throwingAsPOSIXErrorIfNecessary()
    }
    
    public func unlockRawMemoryOutFromRAM() throws {
        try munlock(unsafeRawPointerRepresentation, .init(count) * MemoryLayout<Element>.size).throwingAsPOSIXErrorIfNecessary()
    }
}
