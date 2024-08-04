//
// Copyright (c) Vatsal Manot
//

import Swift

public struct AnySendable: Sendable {
    public let base: any Sendable
    
    public init(erasing x: any Sendable) {
        self.base = x
    }
}

public struct AnyHashableSendable: Hashable, Sendable {
    public let base: any Hashable & Sendable
    
    public init(erasing x: some Hashable & Sendable) {
        self.base = x
    }

    public init(_ x: some Hashable & Sendable) {
        self.init(erasing: x)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        type(of: lhs) == type(of: rhs) && lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(base)
        hasher.combine(ObjectIdentifier(type(of: base)))
    }
}
