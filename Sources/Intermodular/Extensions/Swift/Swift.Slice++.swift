//
// Copyright (c) Vatsal Manot
//

import Swift

extension Slice {
    public init(_ base: Base) {
        self.init(base: base, bounds: base.bounds)
    }
}

extension Slice: ExpressibleByUnicodeScalarLiteral where Base: ExpressibleByUnicodeScalarLiteral {
    public typealias UnicodeScalarLiteralType = Base.UnicodeScalarLiteralType
    
    public init(unicodeScalarLiteral value: Base.UnicodeScalarLiteralType) {
        self.init(Base(unicodeScalarLiteral: value))
    }
}

extension Slice: ExpressibleByExtendedGraphemeClusterLiteral where Base: ExpressibleByExtendedGraphemeClusterLiteral {
    public typealias ExtendedGraphemeClusterLiteralType = Base.ExtendedGraphemeClusterLiteralType
    
    public init(extendedGraphemeClusterLiteral value: Base.ExtendedGraphemeClusterLiteralType) {
        self.init(Base(extendedGraphemeClusterLiteral: value))
    }
}

extension Slice: ExpressibleByStringLiteral where Base: ExpressibleByStringLiteral {
    public typealias StringLiteralType = Base.StringLiteralType
        
    public init(stringLiteral value: Base.StringLiteralType) {
        self.init(Base(stringLiteral: value))
    }
}

extension Slice: CustomStringConvertible where Base.SubSequence: CustomStringConvertible {
    public var description: String {
        return base[bounds].description
    }
}
