//
// Copyright (c) Vatsal Manot
//

import Foundation

@propertyWrapper
public final class _GlobalSetOnceOrTaskLocal<Value: Sendable>: @unchecked Sendable {
    private let id = ObjectIdentifier(_GlobalSetOnceOrTaskLocalIdentity())
    private let defaultValue: Value
    private let state = _OSUnfairLocked(initialState: State())
    
    public var wrappedValue: Value {
        if let fixedValue: Value = state.withCriticalScope({ state in
            state.fixedValue?.value(as: Value.self)
        }) {
            return fixedValue
        }
        
        if let taskLocalValue: Value = _GlobalSetOnceOrTaskLocalValues.values[id]?.value(as: Value.self) {
            return taskLocalValue
        }
        
        return defaultValue
    }
    
    public var projectedValue: _GlobalSetOnceOrTaskLocal<Value> {
        self
    }
    
    public var isValueFixed: Bool {
        state.withCriticalScope { state in
            state.fixedValue != nil
        }
    }
    
    public var _isTaskLocalValueActive: Bool {
        _GlobalSetOnceOrTaskLocalValues.values[id] != nil
    }
    
    public init(
        wrappedValue defaultValue: Value
    ) {
        self.defaultValue = defaultValue
    }
    
    public func withValue<R>(
        _ value: Value,
        operation: () throws -> R
    ) rethrows -> R {
        _beginTaskLocalOverride()
        
        var values = _GlobalSetOnceOrTaskLocalValues.values
        values[id] = _GlobalSetOnceOrTaskLocalValueBox(value)
        
        defer {
            _endTaskLocalOverride()
        }
        
        return try _GlobalSetOnceOrTaskLocalValues.$values.withValue(values) {
            try operation()
        }
    }
    
    public func withValue<R>(
        _ value: Value,
        operation: () async throws -> R
    ) async rethrows -> R {
        _beginTaskLocalOverride()
        
        var values = _GlobalSetOnceOrTaskLocalValues.values
        values[id] = _GlobalSetOnceOrTaskLocalValueBox(value)
        
        defer {
            _endTaskLocalOverride()
        }
        
        return try await _GlobalSetOnceOrTaskLocalValues.$values.withValue(values) {
            try await operation()
        }
    }
    
    public func fixValue(
        _ value: Value
    ) {
        state.withCriticalScope { state in
            precondition(
                state.fixedValue == nil,
                "_GlobalSetOnceOrTaskLocal value has already been fixed."
            )
            precondition(
                state.activeTaskLocalOverrideCount == 0,
                "_GlobalSetOnceOrTaskLocal value cannot be fixed while a task-local override is active."
            )
            precondition(
                !_isTaskLocalValueActive,
                "_GlobalSetOnceOrTaskLocal value cannot be fixed while a task-local override is active."
            )
            
            state.fixedValue = _GlobalSetOnceOrTaskLocalValueBox(value)
        }
    }
    
    private func _beginTaskLocalOverride() {
        state.withCriticalScope { state in
            precondition(
                state.fixedValue == nil,
                "_GlobalSetOnceOrTaskLocal value cannot be task-locally overridden after it has been fixed."
            )
            
            state.activeTaskLocalOverrideCount += 1
        }
    }
    
    private func _endTaskLocalOverride() {
        state.withCriticalScope { state in
            precondition(state.activeTaskLocalOverrideCount > 0)
            
            state.activeTaskLocalOverrideCount -= 1
        }
    }
    
    private struct State: Sendable {
        var fixedValue: (any _AnyGlobalSetOnceOrTaskLocalValueBox)?
        var activeTaskLocalOverrideCount: Int = 0
    }
}

private final class _GlobalSetOnceOrTaskLocalIdentity: Sendable {
    
}

private protocol _AnyGlobalSetOnceOrTaskLocalValueBox: Sendable {
    func value<Value: Sendable>(
        as type: Value.Type
    ) -> Value?
}

private struct _GlobalSetOnceOrTaskLocalValueBox<Value: Sendable>: _AnyGlobalSetOnceOrTaskLocalValueBox {
    let value: Value
    
    init(
        _ value: Value
    ) {
        self.value = value
    }
    
    func value<T: Sendable>(
        as type: T.Type
    ) -> T? {
        value as? T
    }
}

private enum _GlobalSetOnceOrTaskLocalValues {
    @TaskLocal
    static var values: [ObjectIdentifier: any _AnyGlobalSetOnceOrTaskLocalValueBox] = [:]
}
