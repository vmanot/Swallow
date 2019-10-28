//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol OptionalProtocol: opaque_Optional, MutableEitherRepresentable, ExpressibleByNilLiteral where RightValue == Void {
    typealias Wrapped = LeftValue
}

// MARK: - Helpers -

extension Optional {
    public init<T: OptionalProtocol>(_ wrapped: T) where T.Wrapped == Wrapped {
        self = wrapped.leftValue
    }
}

// MARK: - Protocol Implementations -

extension ExpressibleByNilLiteral where Self: OptionalProtocol {
    public init(nilLiteral: ()) {
        self.init(Optional<Wrapped>.none)
    }
}
