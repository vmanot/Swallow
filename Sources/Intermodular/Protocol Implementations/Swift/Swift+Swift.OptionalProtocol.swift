//
// Copyright (c) Vatsal Manot
//

import Swift

public enum NilUnequalOptional<Wrapped>: OptionalProtocol {
    case some(Wrapped)
    case none
    
    public var eitherValue: Either<Wrapped, Void> {
        get {
            switch self {
            case .some(let value):
                return .left(value)
            case .none:
                return .right(())
            }
        } set {
            self = .init(newValue)
        }
    }
    
    public init(_ eitherValue: Either<Wrapped, Void>) {
        self = eitherValue.reduce(NilUnequalOptional.some, .none)
    }
    
    public init(none: Void) {
        self = .none
    }
}

extension NilUnequalOptional: Equatable where Wrapped: Equatable {
    public static func == (lhs: NilUnequalOptional, rhs: NilUnequalOptional) -> Bool {
        switch (lhs, rhs) {
        case (.some(let x), .some(let y)):
            return x == y
        default:
            return false
        }
    }
}

extension NilUnequalOptional: Codable where Wrapped: Codable {
    public func encode(to encoder: Encoder) throws {
        try Optional<Wrapped>(self).encode(to: encoder)
    }
    
    public init(from decoder: Decoder) throws {
        self.init(try Optional<Wrapped>(from: decoder))
    }
}

extension NilUnequalOptional: ExpressibleByExtendedGraphemeClusterLiteral where Wrapped: ExpressibleByExtendedGraphemeClusterLiteral {
    public typealias ExtendedGraphemeClusterLiteralType = Wrapped.ExtendedGraphemeClusterLiteralType
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(.some(Wrapped(extendedGraphemeClusterLiteral: value)))
    }
}

extension NilUnequalOptional: ExpressibleByUnicodeScalarLiteral where Wrapped: ExpressibleByUnicodeScalarLiteral {
    public typealias UnicodeScalarLiteralType = Wrapped.UnicodeScalarLiteralType
    
    public init(unicodeScalarLiteral value: Wrapped.UnicodeScalarLiteralType) {
        self.init(.some(Wrapped(unicodeScalarLiteral: value)))
    }
}

extension NilUnequalOptional: ExpressibleByStringLiteral where Wrapped: ExpressibleByStringLiteral {
    public typealias StringLiteralType = Wrapped.StringLiteralType
    
    public init(stringLiteral value: Wrapped.StringLiteralType) {
        self.init(.some(Wrapped(stringLiteral: value)))
    }
}
