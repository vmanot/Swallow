//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public class POSIXIndirect<Primitive>: Initiable {
    public var value: UnsafeMutablePointer<Primitive>?

    public required init(_ value: UnsafeMutablePointer<Primitive>?) {
        self.value = value
    }

    public required convenience init() {
        self.init(nil)
    }
    
    public func construct() throws {
        guard value == nil else {
            throw _PlaceholderError()
        }

        value = .allocate(capacity: 1)
    }

    public func destruct() throws {
        try value.unwrap().deinitialize(count: 1)
        try value.unwrap().deallocate()
    }

    public func withConstructedValue<Result>(_ body: ((UnsafeMutablePointer<Primitive>) throws -> Result)) throws -> Result {
        return try body(value.unwrap())
    }
}
