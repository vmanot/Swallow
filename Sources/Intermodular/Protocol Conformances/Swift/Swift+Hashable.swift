//
// Copyright (c) Vatsal Manot
//

import Swift

extension Either: Hashable where LeftValue: Hashable, RightValue: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(isLeft)
        hasher.combine(reduce(AnyHashable.init, AnyHashable.init))
    }
}

public struct Empty: _opaque_Hashable, Codable, Hashable {
    public init() {
        
    }
}

public struct HashableImplOnly<Value: Hashable>: Hashable {
    public let value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
}

public struct Hashable2ple<T: Hashable, U: Hashable>: Hashable, Wrapper {
    public typealias Value = (T, U)
    
    public let value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
    
    public init(_ value0: T, _ value1: U) {
        self.value = (value0, value1)
    }
    
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value.0)
        hasher.combine(value.1)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value.0 == rhs.value.0 && lhs.value.1 == rhs.value.1
    }
}

public struct ManyHashable: Hashable {
    @usableFromInline
    let hashIntoHasherImpl: (inout Hasher) -> ()

    @inlinable
    public init<H0: Hashable, H1: Hashable>(_ h0: H0, _ h1: H1) {
        hashIntoHasherImpl = {
            h0.hash(into: &$0)
            h1.hash(into: &$0)
        }
    }
    
    @inlinable
    public init<H0: Hashable, H1: Hashable, H2: Hashable>(_ h0: H0, _ h1: H1, _ h2: H2) {
        hashIntoHasherImpl = {
            h0.hash(into: &$0)
            h1.hash(into: &$0)
            h2.hash(into: &$0)
        }
    }
    
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hashIntoHasherImpl(&hasher)
    }
    
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
