//
// Copyright (c) Vatsal Manot
//

import Swallow

extension _ObjectiveCBridgeable {
    public static func _conditionallyBridgeFromObjectiveC(_ source: _ObjectiveCType) -> Self? {
        var result: Self?
        _conditionallyBridgeFromObjectiveC(source, result: &result)
        return result
    }

    public func _safelyBridgeToObjectiveC(_ type: _ObjectiveCType.Type) -> _ObjectiveCType {
        guard ObjectIdentifier(type) == ObjectIdentifier(_ObjectiveCType.self) else {
            fatalError("Bridging to subclasses is not supported yet.")
        }
        return _bridgeToObjectiveC()
    }
}
