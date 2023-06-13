//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public struct _LockedState<State> {
    private let _buffer: ManagedBuffer<State, _Lock.Primitive>
    
    public init(initialState: State) {
        _buffer = _Buffer.create(minimumCapacity: 1, makingHeaderWith: { buf in
            buf.withUnsafeMutablePointerToElements {
                _Lock.initialize($0)
            }
            return initialState
        })
    }
    
    public func withLock<T>(
        _ body: @Sendable (inout State) throws -> T
    ) rethrows -> T {
        try withLockUnchecked(body)
    }
    
    public func withLockUnchecked<T>(
        _ body: (inout State) throws -> T
    ) rethrows -> T {
        try _buffer.withUnsafeMutablePointers { state, lock in
            _Lock.lock(lock)
            defer { _Lock.unlock(lock) }
            return try body(&state.pointee)
        }
    }
    
    // Ensures the managed state outlives the locked `body`.
    public func withLockExtendingLifetimeOfState<T>(
        _ body: @Sendable (inout State) throws -> T
    ) rethrows -> T {
        try _buffer.withUnsafeMutablePointers { state, lock in
            _Lock.lock(lock)
            return try withExtendedLifetime(state.pointee) {
                let result = try body(&state.pointee)
                _Lock.unlock(lock)
                return result
            }
        }
    }
}

extension _LockedState: @unchecked Sendable where State: Sendable {
    
}

// MARK: - Auxiliary
extension _LockedState {
    private struct _Lock {
        typealias Primitive = os_unfair_lock
        
        typealias PlatformLock = UnsafeMutablePointer<Primitive>
        var _platformLock: PlatformLock
        
        fileprivate static func initialize(_ platformLock: PlatformLock) {
            platformLock.initialize(to: os_unfair_lock())
        }
        
        fileprivate static func deinitialize(_ platformLock: PlatformLock) {
            platformLock.deinitialize(count: 1)
        }
        
        static fileprivate func lock(_ platformLock: PlatformLock) {
            os_unfair_lock_lock(platformLock)
        }
        
        static fileprivate func unlock(_ platformLock: PlatformLock) {
            os_unfair_lock_unlock(platformLock)
        }
    }
    
    private class _Buffer: ManagedBuffer<State, _Lock.Primitive> {
        deinit {
            withUnsafeMutablePointerToElements {
                _Lock.deinitialize($0)
            }
        }
    }
}
