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
    
    @inlinable
    public func withMutableScope(_ body: ((inout Self) throws -> Void)) rethrows -> Self {
        var result = self
        
        try body(&result)
        
        return result
    }
}

extension AnyProtocol {
    @inlinable
    public func mapSelf<T>(_ f: ((Self) throws -> T)) rethrows -> T {
        try f(self)
    }
}

// MARK: - Debugging -

extension AnyProtocol {
    public func printSelf() {
        mapSelf({ print($0) })
    }
    
    public func printingSelf() -> Self {
        print(self)
        
        return self
    }
}
