//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol OptionalProtocol: _opaque_Optional, MutableEitherRepresentable where RightValue == Void {
    typealias Wrapped = LeftValue
}

// MARK: - Helpers -

extension Optional {
    public init<T: OptionalProtocol>(_ wrapped: T) where T.Wrapped == Wrapped {
        self = wrapped.leftValue
    }
}

// MARK: - Conformances -

extension ExpressibleByNilLiteral where Self: OptionalProtocol {
    public init(nilLiteral: ()) {
        self.init(Optional<Wrapped>.none)
    }
}
