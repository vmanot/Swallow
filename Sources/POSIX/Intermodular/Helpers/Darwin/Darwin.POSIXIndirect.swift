//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow
import SwallowMacrosClient

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
            #throw
        }

        value = .allocate(capacity: 1)
    }

    public func destruct() throws {
        let value = try self.value.unwrap()

        value.deinitialize(count: 1)
        value.deallocate()
        self.value = nil
    }

    public func withConstructedValue<Result>(_ body: ((UnsafeMutablePointer<Primitive>) throws -> Result)) throws -> Result {
        return try body(value.unwrap())
    }
}
