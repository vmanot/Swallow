//
// Copyright (c) Vatsal Manot
//

import Darwin

public struct _LockedStateMap<Key: Hashable, Value> {
    @_LockedState
    private var state: [Key: _LockedState<Value>] = [:]
    
    public init(initialState: [Key: Value]) {
        self.state = initialState.mapValues({ _LockedState(initialState: $0) })
    }
    
    public subscript(
        _ key: Key,
        default defaultValue: @autoclosure () -> Value
    ) -> _LockedState<Value> {
        get {
            $state.withLock { state in
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
        self[key, default: .init()]
    }
}

extension _LockedStateMap: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(initialState: Dictionary(uniqueKeysWithValues: elements))
    }
}
