//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol ScopedLogger: LoggerProtocol {
    associatedtype Scope: LogScope
    associatedtype ScopedLogger: LoggerProtocol
    
    func scoped(to scope: Scope) throws -> ScopedLogger
}

extension ScopedLogger where Scope == AnyLogScope {
    public func scoped<Scope: LogScope>(to scope: Scope) throws -> ScopedLogger {
        try scoped(to: .init(erasing: scope))
    }
}

@_typeEraser(AnyLogScope)
public protocol LogScope: CustomStringConvertible, Hashable {
    
}

public struct AnyLogScope: _UnwrappableTypeEraser, LogScope {
    public typealias _UnwrappedBaseType = any LogScope
    
    private let base: _UnwrappedBaseType
    
    public init(_erasing base: _UnwrappedBaseType) {
        self.base = base
    }
    
    public var description: String {
        base.description
    }
    
    public init<T: LogScope>(erasing base: T) {
        self.base = base
    }
    
    public func _unwrapBase() -> any LogScope {
        base
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(base)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        AnyEquatable.equate(lhs.base, rhs.base)
    }
}
