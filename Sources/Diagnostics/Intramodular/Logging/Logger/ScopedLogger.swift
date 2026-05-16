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
