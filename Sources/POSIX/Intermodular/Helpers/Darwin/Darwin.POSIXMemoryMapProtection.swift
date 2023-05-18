//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public struct POSIXMemoryMapProtection: RawRepresentable {
    public typealias RawValue = Int32
    
    public let rawValue: RawValue
    
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

extension POSIXMemoryMapProtection: OptionSet {
    public static let execute = with(rawValue: PROT_EXEC)
    public static let read = with(rawValue: PROT_READ)
    public static let write = with(rawValue: PROT_WRITE)
    public static let none = with(rawValue: PROT_NONE)
}
