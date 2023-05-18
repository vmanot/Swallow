//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public struct POSIXMemoryMapOtherFlags: Initiable, OptionSet {
    public typealias RawValue = Int32
    
    public static let fixed = with(rawValue: MAP_FIXED)
    public static let rename = with(rawValue: MAP_RENAME)
    public static let doNotReserveSwapArea = with(rawValue: MAP_NORESERVE)
    public static let containsSemaphores = with(rawValue: MAP_HASSEMAPHORE)
    public static let doNotCache = with(rawValue: MAP_NOCACHE)
    public static let forJIT = with(rawValue: MAP_JIT)

    public let rawValue: RawValue
    
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    
    public init() {
        self.init(rawValue: 0)
    }
}
