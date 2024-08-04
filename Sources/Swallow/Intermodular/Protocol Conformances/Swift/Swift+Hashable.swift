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

@frozen
public struct EmptyValue: Codable, Hashable, Sendable {
    public init() {
        
    }
}

@frozen
public struct HashableImplOnly<Value: Hashable>: Hashable {
    public let value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
}

@frozen
public struct Hashable2ple<T0: Hashable, T1: Hashable>: Hashable, Wrapper {
    public let value: (T0, T1)
    
    @inline(__always)
    public init(_ value: (T0, T1)) {
        self.value = value
    }
        
    @inline(__always)
    public init<A, B>(_ value: (T0, A, B)) where T1 == Hashable2ple<A, B> {
        let first = value.0
        let next = Hashable2ple<A, B>((value.1, value.2))
        
        self.init((first, next))
    }
    
    @inline(__always)
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value.0)
        hasher.combine(value.1)
    }
    
    @inline(__always)
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value.0 == rhs.value.0 && lhs.value.1 == rhs.value.1
    }
}

@frozen
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

@frozen
public struct _CodableVoid: Codable, Hashable, Sendable {
    public init() {
        
    }
}
