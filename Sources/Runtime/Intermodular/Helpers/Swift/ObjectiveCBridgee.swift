//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

public protocol ObjectiveCBridgee {
    associatedtype SwiftType: _ObjectiveCBridgeable
}

extension DataEncodable where Self: ObjectiveCBridgee, Self.SwiftType: DataEncodable, Self.DataEncodingStrategy == Self.SwiftType.DataEncodingStrategy, SwiftType._ObjectiveCType == Self {
    public func data(using strategy: DataEncodingStrategy) throws -> Data {
        return try SwiftType
            ._conditionallyBridgeFromObjectiveC(self)
            .unwrap()
            .data(using: strategy)
    }
}

extension DataEncodable where Self: ObjectiveCBridgee, Self.SwiftType: DataEncodableWithDefaultStrategy, Self.DataEncodingStrategy == Self.SwiftType.DataEncodingStrategy {
    public static var defaultDataEncodingStrategy: DataEncodingStrategy {
        return SwiftType.defaultDataEncodingStrategy
    }
}

extension DataDecodable where Self: ObjectiveCBridgee, Self.SwiftType: DataDecodable, Self.DataDecodingStrategy == Self.SwiftType.DataDecodingStrategy, SwiftType._ObjectiveCType == Self {
    public init(data: Data, using strategy: DataDecodingStrategy) throws {
        self = try SwiftType(data: data, using: strategy)._bridgeToObjectiveC()
    }
}

extension DataDecodable where Self: ObjectiveCBridgee, Self.SwiftType: DataDecodableWithDefaultStrategy, Self.DataDecodingStrategy == Self.SwiftType.DataDecodingStrategy {
    public static var defaultDataDecodingStrategy: DataDecodingStrategy {
        return SwiftType.defaultDataDecodingStrategy
    }
}
