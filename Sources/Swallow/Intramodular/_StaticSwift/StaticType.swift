//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type that represents a static construct.
///
/// For e.g. `StaticString`.
public protocol _StaticType: Sendable {
    
}

/// A type that has no instance data (i.e. init() doesn't really make a difference).
///
/// This is **not** to be confused with the singleton pattern.
public protocol _StaticInstance: Hashable, Identifiable, Initiable, Sendable where ID == Metatype<Self.Type> {
    var id: Metatype<Self.Type> { get }
}

/// A type that specifies a domain.
public protocol _StaticDomainSpecifying {
    associatedtype _DomainType
}

// MARK: - Default Implementation

extension _StaticInstance {
    public var id: Metatype<Self.Type> {
        .init(type(of: self))
    }
}

extension Bool {
    public struct True: _StaticBoolean {
        public static let value: Bool = true
    }
    
    public struct False: _StaticBoolean {
        public static let value: Bool = false
    }
}
