//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol UnmanagedProtocol {
    associatedtype Instance
    
    static func passUnretained(_ value: Instance) -> Self
    
    func takeUnretainedValue() -> Instance
    func takeRetainedValue() -> Instance
    
    func retain() -> Self
    func release()
}

// MARK: - Extensions

extension UnmanagedProtocol {
    public var unretainedValue: Instance {
        get {
            return takeUnretainedValue()
        } set {
            self = .passUnretained(newValue)
        }
    }
    
    public var retainedValue: Instance {
        get {
            return takeRetainedValue()
        } set {
            self = .passRetained(newValue)
        }
    }
    
    public static func passRetained(_ value: Instance) -> Self {
        let result = passUnretained(value)
        
        _ = result.retain()
        
        return result
    }
    
    public static func withUnretainedValue<Result>(
        _ value: Instance,
        _ body: ((Self) throws -> Result)
    ) rethrows -> Result {
        return try body(.passUnretained(value))
    }
    
    public static func withRetainedValue<Result>(
        _ value: Instance,
        _ body: ((Self) throws -> Result)
    ) rethrows -> Result {
        return try body(.passRetained(value))
    }
    
    public static func withUnretainedValue<Result>(
        _ value: inout Instance,
        _ body: ((inout Self) throws -> Result)
    ) rethrows -> Result {
        var unmanaged = passUnretained(value)
        
        defer {
            value = unmanaged.takeUnretainedValue()
        }
        
        return try body(&unmanaged)
    }
    
    public func takeRetainedValue() -> Any {
        _ = retain()
        return takeUnretainedValue()
    }
}

// MARK: - Implementation

extension Unmanaged: UnmanagedProtocol {
    
}
