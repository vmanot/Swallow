//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol AnyProtocol {
    
}

// MARK: - Extensions -

extension AnyProtocol {
    public typealias _Self = Self
}

extension AnyProtocol {
    @inlinable
    @_disfavoredOverload
    public func then(_ f: ((inout Self) throws -> Void)) rethrows -> Self {
        var result = self
        try f(&result)
        return result
    }
    
    @discardableResult
    @inlinable
    public func then(_ f: ((Self) throws -> Void)) rethrows -> Self where Self: AnyObject {
        try f(self)
        
        return self
    }
}

extension AnyProtocol {
    @inlinable
    public func applyingOnSelf<T>(_ f: ((inout Self) throws -> T)) rethrows -> Self {
        var result = self
        
        _ = try f(&result)
        
        return result
    }
    
    @inlinable
    public func applyingSelfOn<T>(_ f: ((Self) throws -> T)) rethrows -> Self {
        _ = try f(self)
        
        return self
    }
    
    @inlinable
    public mutating func applyingSelfOn<T>(_ f: ((inout Self) throws -> T)) rethrows -> Self {
        _ = try f(&self)
        
        return self
    }
}

extension AnyProtocol {
    @inlinable
    public func mapSelf<T>(_ f: ((Self) throws -> T)) rethrows -> T {
        return try f(self)
    }
}

// MARK: - Debugging -

extension AnyProtocol {
    public func printSelf() {
        mapSelf({ print($0) })
    }
    
    public func printSelfWithDebugInformation() {
        mapSelf({ print("\($0) (\(type(of: $0)))") })
    }
    
    public func printingSelf() -> Self {
        return applyingSelfOn({ print($0) })
    }
}
