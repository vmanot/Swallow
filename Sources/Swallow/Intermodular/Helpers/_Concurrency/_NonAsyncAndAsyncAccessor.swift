//
// Copyright (c) Vatsal Manot
//

import Swift

public struct _NonAsyncAndAsyncAccessor<Root, Value> {
    private let _getNonAsync: (Root) throws -> Value
    private let _getAsync: (Root) async throws -> Value
    private let _setNonAsync: (Root, Value) throws -> Void
    private let _setAsync: (Root, Value) async throws -> Void
    
    public struct _NonAsyncBase {
        let get: (Root) throws -> Value
        let set: (Root, Value) throws -> Void
        
        public init(
            get: @escaping (Root) throws -> Value,
            set: @escaping (Root, Value) throws -> Void
        ) {
            self.get = get
            self.set = set
        }
        
        public init(
            get: @escaping () throws -> Value,
            set: @escaping (Value) throws -> Void
        ) where Root == Void {
            self.get = { (root: Void) in
                try get()
            }
            self.set = { (root: Void, newValue: Value) in
                try set(newValue)
            }
        }
    }
    
    public struct _AsyncBase {
        let get: (Root) async throws -> Value
        let set: (Root, Value) async throws -> Void
        
        public init(
            get: @escaping (Root) async throws -> Value,
            set: @escaping (Root, Value) async throws -> Void
        ) {
            self.get = get
            self.set = set
        }
        
        public init(
            get: @escaping () async throws -> Value,
            set: @escaping (Value) async throws -> Void
        ) where Root == Void {
            self.get = { (root: Void) in
                try await get()
            }
            self.set = { (root: Void, newValue: Value) in
                try await set(newValue)
            }
        }
    }
    
    public init(
        nonAsync: _NonAsyncBase,
        async: _AsyncBase
    ) {
        self._getNonAsync = nonAsync.get
        self._getAsync = async.get
        self._setNonAsync = nonAsync.set
        self._setAsync = async.set
    }
}

extension _NonAsyncAndAsyncAccessor where Root == Void {
    public var value: Value {
        get async throws {
            try await self._getAsync(())
        }
    }
    
    public var synchronouslyAccessedValue: Value {
        get async throws {
            try self._getNonAsync(())
        }
    }
    
    public func setValue(_ newValue: Value) async throws {
        try await self._setAsync((), newValue)
    }
    
    public func synchronouslySetValue(_ newValue: Value) throws {
        try self._setNonAsync((), newValue)
    }
}
