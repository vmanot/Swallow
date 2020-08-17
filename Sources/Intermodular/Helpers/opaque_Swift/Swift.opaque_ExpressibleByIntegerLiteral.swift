//
// Copyright (c) Vatsal Manot
//

import Swift

public typealias ExpressibleByIntegerLiteral2 = _opaque_ExpressibleByIntegerLiteral & ExpressibleByIntegerLiteral

public protocol _opaque_ExpressibleByIntegerLiteral: AnyProtocol {
    init(integerLiteral value: UInt8)
}

extension _opaque_ExpressibleByIntegerLiteral where Self: ExpressibleByIntegerLiteral, Self.IntegerLiteralType: SignedInteger {
    public init(integerLiteral value: UInt8) {
        self.init(integerLiteral: IntegerLiteralType(Int64(value)))
    }
}

extension _opaque_ExpressibleByIntegerLiteral where Self: ExpressibleByIntegerLiteral, Self.IntegerLiteralType: UnsignedInteger {
    public init(integerLiteral value: UInt8) {
        self.init(integerLiteral: IntegerLiteralType(UInt64(value)))
    }
}
