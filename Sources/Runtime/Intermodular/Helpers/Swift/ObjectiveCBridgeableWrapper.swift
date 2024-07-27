//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol ObjectiveCBridgeableWrapper: _ObjectiveCBridgeable, Wrapper {
    var value: _ObjectiveCType { get }
    
    init(_: _ObjectiveCType)
}

// MARK: - Implementation

extension ObjectiveCBridgeableWrapper {
    public func _bridgeToObjectiveC() -> _ObjectiveCType {
        return value
    }
    
    public static func _forceBridgeFromObjectiveC(_ source: _ObjectiveCType, result: inout Self?) {
        try! _conditionallyBridgeFromObjectiveC(source, result: &result).orThrow()
    }
    
    @discardableResult
    public static func _conditionallyBridgeFromObjectiveC(_ source: _ObjectiveCType, result: inout Self?) -> Bool {
        result = Self(source)
        
        return true
    }
    
    public static func _unconditionallyBridgeFromObjectiveC(_ source: _ObjectiveCType?) -> Self {
        return .init(try! source.forceUnwrap())
    }
}
