//
// Copyright (c) Vatsal Manot
//

import Swift

extension Either: Equatable where LeftValue: Equatable, RightValue: Equatable {
    public static func == (lhs: Either, rhs: Either) -> Bool {
        switch (lhs, rhs) {
        case (.left(let x), .left(let y)):
            return x == y
        case (.right(let x), .right(let y)):
            return x == y
        default:
            return false
        }
    }
}

extension Either: Hashable where LeftValue: Hashable, RightValue: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(isLeft)
        hasher.combine(reduce(AnyHashable.init, AnyHashable.init))
    }
}

public struct Empty: Codable, Hashable2 {
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
}
