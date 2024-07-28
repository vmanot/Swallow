//
// Copyright (c) Vatsal Manot
//

import Darwin

@dynamicMemberLookup
@propertyWrapper
@frozen
public struct _LockedState<State> {
    @usableFromInline
    let _buffer: ManagedBuffer<State, _Lock.Primitive>
    
    public var wrappedValue: State {
        get {
            withLock {
                $0
            }
        } nonmutating set {
            withLock {
                $0 = newValue
            }
        }
    }
    
    public var projectedValue: Self {
        @_transparent
        _read {
            yield self
        }
        
        @_transparent
        _modify {
            yield &self
        }
    }
    
    @_transparent
    public init(initialState: State) {
        _buffer = _Buffer.create(minimumCapacity: 1, makingHeaderWith: { buf in
            buf.withUnsafeMutablePointerToElements {
                _Lock.initialize($0)
            }
            return initialState
        })
    }
    
    @_transparent
    public init(wrappedValue: State) {
        self.init(initialState: wrappedValue)
    }
    
    public subscript<T>(dynamicMember keyPath: KeyPath<State, T>) -> T {
        @_transparent
        get {
            withLock {
                $0[keyPath: keyPath]
            }
        }
    }
    
    @_transparent
    public func withLock<T>(
        _ body: @Sendable (inout State) throws -> T
    ) rethrows -> T {
        try withLockUnchecked(body)
    }
    
    @_transparent
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
    @_transparent
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

extension _LockedState {
    @_transparent
    public func memoizing<T>(
        _ keyPath: WritableKeyPath<State, T?>,
        _ body: (State) -> T
    ) -> T {
        withLock { (state: inout State) in
            if let value = state[keyPath: keyPath] {
                return value
            } else {
                let value = body(state)
                
                state[keyPath: keyPath] = value
                
                return value
            }
        }
    }
        
    @_transparent
    public func memoizing<T>(
        _ keyPath: WritableKeyPath<State, T?>,
        _ body: () -> T
    ) -> T {
        withLock { (state: inout State) in
            if let value = state[keyPath: keyPath] {
                return value
            } else {
                let value = body()
                
                state[keyPath: keyPath] = value
                
                return value
            }
        }
    }
    
    @_transparent
    public func memoizing<T>(
        _ keyPath: KeyPath<State.KeysType, T>,
        _ body: (State) -> T
    ) -> T where State: _KeyPathKeyedDictionary {
        withLock { (state: inout State) in
            if let value: T = state[_key: keyPath] {
                return value
            } else {
                let value = body(state)
                
                state[_key: keyPath] = value
                
                return value
            }
        }
    }

    @_transparent
    public func memoizing<T>(
        _ keyPath: KeyPath<State.KeysType, T>,
        _ body: () -> T
    ) -> T where State: _KeyPathKeyedDictionary {
        withLock { (state: inout State) in
            if let value: T = state[_key: keyPath] {
                return value
            } else {
                let value = body()
                
                state[_key: keyPath] = value
                
                return value
            }
        }
    }

    @_transparent
    public func memoizing<T>(
        _ keyPath: KeyPath<State.KeysType, T?>,
        _ body: () -> T
    ) -> T where State: _KeyPathKeyedDictionary {
        withLock { (state: inout State) in
            if let value: T = (state[_key: keyPath]).flatMap({ $0 }) {
                return value
            } else {
                let value = body()
                
                state[_key: keyPath] = value
                
                return value
            }
        }
    }
    
    @_transparent
    public func memoizing<T: Initiable>(
        _ keyPath: KeyPath<State.KeysType, T?>
    ) -> T where State: _KeyPathKeyedDictionary {
        memoizing(keyPath, { T.init() })
    }
}

extension _LockedState: @unchecked Sendable where State: Sendable {
    
}

// MARK: - Auxiliary
extension _LockedState {
    @usableFromInline
    struct _Lock {
        @usableFromInline
        typealias Primitive = os_unfair_lock
        @usableFromInline
        typealias PlatformLock = UnsafeMutablePointer<Primitive>
        
        @usableFromInline
        var _platformLock: PlatformLock
        
        @_transparent
        init(_platformLock: PlatformLock) {
            self._platformLock = _platformLock
        }
        
        @_transparent
        public static func initialize(_ platformLock: PlatformLock) {
            platformLock.initialize(to: os_unfair_lock())
        }
        
        @_transparent
        public static func deinitialize(_ platformLock: PlatformLock) {
            platformLock.deinitialize(count: 1)
        }
        
        @_transparent
        public static func lock(_ platformLock: PlatformLock) {
            os_unfair_lock_lock(platformLock)
        }
        
        @_transparent
        public static func unlock(_ platformLock: PlatformLock) {
            os_unfair_lock_unlock(platformLock)
        }
    }
    
    @usableFromInline
    class _Buffer: ManagedBuffer<State, _Lock.Primitive> {
        deinit {
            withUnsafeMutablePointerToElements {
                _Lock.deinitialize($0)
            }
        }
    }
}
