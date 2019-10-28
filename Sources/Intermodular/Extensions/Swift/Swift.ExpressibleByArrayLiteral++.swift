//
// Copyright (c) Vatsal Manot
//

import Swift

extension ExpressibleByArrayLiteral {
    /// Creates an instance initialized with the given elements.
    public init(_arrayLiteral elements: [Self.ArrayLiteralElement]) {
        self = isovariadic(Self.init(arrayLiteral:))(elements)
    }
}
