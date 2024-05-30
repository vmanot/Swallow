//
// Copyright (c) Vatsal Manot
//

import Darwin

/// An `os_unfair_lock` wrapper.
@_spi(Internal)
public final class OSUnfairLock: @unchecked Sendable {
    @usableFromInline
    let base: os_unfair_lock_t
    
    @_optimize(speed)
    public init() {
        let base = os_unfair_lock_t.allocate(capacity: 1)
        
        base.initialize(repeating: os_unfair_lock_s(), count: 1)
        
        self.base = base
    }
    
    @_optimize(speed)
    @inlinable
    @inline(__always)
    public func acquireOrBlock() {
        os_unfair_lock_lock(base)
    }
    
    @usableFromInline
    enum AcquisitionError: Error {
        case failedToAcquireLock
    }
    
    @_optimize(speed)
    @inlinable
    @inline(__always)
    public func acquireOrFail() throws {
        let didAcquire = os_unfair_lock_trylock(base)
        
        if !didAcquire {
            throw AcquisitionError.failedToAcquireLock
        }
    }
    
    @_optimize(speed)
    @inlinable
    @inline(__always)
    public func relinquish() {
        os_unfair_lock_unlock(base)
    }
    
    deinit {
        base.deinitialize(count: 1)
        base.deallocate()
    }
}

@_spi(Internal)
extension OSUnfairLock {
    @_optimize(speed)
    @_transparent
    @inlinable
    @inline(__always)
    public func withCriticalScope<Result>(
        perform action: () throws -> Result
    ) rethrows -> Result {
        let result: Result
        
        acquireOrBlock()
        
        do {
            result = try action()
            
            relinquish()
        } catch {
            relinquish()
            
            throw error
        }
        
        return result
    }
}

@dynamicMemberLookup
@propertyWrapper
public class _OSUnfairLocked<Value>: @unchecked Sendable {
    private var value: Value
    private let lock: OSUnfairLock
    
    public init(wrappedValue: Value) {
        self.value = wrappedValue
        self.lock = OSUnfairLock()
    }
    
    public required convenience init(nilLiteral: ()) where Value: ExpressibleByNilLiteral {
        self.init(wrappedValue: .init(nilLiteral: ()))
    }
    
    public var wrappedValue: Value {
        get {
            lock.withCriticalScope {
                value
            }
        }
        set {
            lock.withCriticalScope {
                value = newValue
            }
        }
    }
    
    public var projectedValue: _OSUnfairLocked<Value> {
        self
    }
    
    public func withCriticalScope<Result>(
        _ action: (inout Value) throws -> Result
    ) rethrows -> Result {
        try lock.withCriticalScope {
            try action(&value)
        }
    }
    
    public subscript<Subject>(
        dynamicMember keyPath: KeyPath<Value, Subject>
    ) -> Subject {
        lock.withCriticalScope {
            value[keyPath: keyPath]
        }
    }
    
    public subscript<Subject>(
        dynamicMember keyPath: WritableKeyPath<Value, Subject>
    ) -> Subject {
        get {
            lock.withCriticalScope {
                value[keyPath: keyPath]
            }
        } set {
            lock.withCriticalScope {
                value[keyPath: keyPath] = newValue
            }
        }
    }
}

extension _OSUnfairLocked: ExpressibleByNilLiteral where Value: ExpressibleByNilLiteral {
    
}
