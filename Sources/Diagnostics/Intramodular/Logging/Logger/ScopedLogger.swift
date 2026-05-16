//
// Copyright (c) Vatsal Manot
//

import Swallow

/// A logger that can derive a child logger for a nested diagnostic context.
///
/// Flat log lines throw away call intent. Scopes keep operation context attached
/// through capture, export, and backend projection.
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

public protocol LogScopeTextRepresentable {
    var logScopeTextRepresentation: LogScopeTextRepresentation { get }
}

public struct LogScopeTextRepresentation: Hashable, Sendable, CustomStringConvertible {
    public struct Segment: Hashable, Sendable, CustomStringConvertible, ExpressibleByStringLiteral {
        public var text: String
        
        public init(
            _ text: String
        ) {
            self.text = text
        }
        
        public init(
            stringLiteral value: String
        ) {
            self.init(value)
        }
        
        public var description: String {
            text
        }
    }
    
    public var segments: [Segment]
    
    public init(
        _ segment: Segment
    ) {
        self.segments = [segment]
    }
    
    public init(
        segments: [Segment]
    ) {
        self.segments = segments
    }
    
    public var description: String {
        segments.map(\.description).joined(separator: " ")
    }
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
    
    public var textRepresentation: LogScopeTextRepresentation {
        if let base = base as? any LogScopeTextRepresentable {
            return base.logScopeTextRepresentation
        } else {
            return LogScopeTextRepresentation(.init(description))
        }
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
