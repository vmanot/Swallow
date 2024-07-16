//
// Copyright (c) Vatsal Manot
//

import Darwin

@frozen
public struct _LockedStateMap<Key: Hashable, Value> {
    @_LockedState
    public var _state: [Key: _LockedState<Value>] = [:]
    
    @_transparent
    public init(initialState: [Key: Value]) {
        self._state = initialState.mapValues({ _LockedState(initialState: $0) })
    }
    
    public subscript(
        _ key: Key,
        default defaultValue: @autoclosure () -> Value
    ) -> _LockedState<Value> {
        @_transparent
        get {
            $_state.withLock { state in
                if let value = state[key] {
                    return value
                } else {
                    let value = _LockedState<Value>(initialState: defaultValue())
                    
                    state[key] = value
                    
                    return value
                }
            }
        }
    }
    
    public subscript(
        _ key: Key
    ) -> _LockedState<Value> where Value: Initiable {
        @_transparent
        get {
            self[key, default: Value()]
        }
    }
}

extension _LockedStateMap: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(initialState: Dictionary(uniqueKeysWithValues: elements))
    }
}
