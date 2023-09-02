//
// Copyright (c) Vatsal Manot
//

import Darwin

/// An `os_unfair_lock` wrapper.
@_spi(Internal)
public final class OSUnfairLock: Sendable {
    @usableFromInline
    let base: os_unfair_lock_t
    
    public init() {
        let base = os_unfair_lock_t.allocate(capacity: 1)
        
        base.initialize(repeating: os_unfair_lock_s(), count: 1)
        
        self.base = base
    }
    
    @inlinable
    @inline(__always)
    public func acquireOrBlock() {
        os_unfair_lock_lock(base)
    }
    
    @usableFromInline
    enum AcquisitionError: Error {
        case failedToAcquireLock
    }
    
    @inlinable
    @inline(__always)
    public func acquireOrFail() throws {
        let didAcquire = os_unfair_lock_trylock(base)
        
        if !didAcquire {
            throw AcquisitionError.failedToAcquireLock
        }
    }
    
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
    @inlinable
    @inline(__always)
    public func withCriticalScope<Result>(
        perform action: () -> Result
    ) -> Result {
        defer {
            relinquish()
        }
        
        acquireOrBlock()
        
        return action()
    }
}
