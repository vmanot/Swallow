//
// Copyright (c) Vatsal Manot
//

import Swift

public struct GeographicalPoint: Codable, Hashable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

// MARK: - Conformances -

#if canImport(CoreLocation)

import CoreLocation

extension GeographicalPoint: ObjectiveCBridgeable {
    public typealias _ObjectiveCType = CLLocation

    public static func bridgeFromObjectiveC(_ source: _ObjectiveCType) throws -> Self {
        return .init(
            latitude: source.coordinate.latitude,
            longitude: source.coordinate.longitude
        )
    }

    public func bridgeToObjectiveC() throws -> _ObjectiveCType {
        return .init(latitude: latitude, longitude: longitude)
    }
}

#endif
