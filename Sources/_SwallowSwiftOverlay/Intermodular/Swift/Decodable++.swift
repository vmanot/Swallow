//
// Copyright (c) Vatsal Manot
//

import Swift

extension Decodable {
    public static func decode<Container: KeyedDecodingContainerProtocol>(
        from container: Container,
        forKey key: Container.Key
    ) throws -> Self {
        try container.decode(Self.self, forKey: key)
    }

    public static func decodeIfPresent<Container: KeyedDecodingContainerProtocol>(
        from container: Container,
        forKey key: Container.Key
    ) throws -> Self? {
        try container.decodeIfPresent(Self.self, forKey: key)
    }

    public static func decodeIfPresent<Container: SingleValueDecodingContainer>(
        from container: Container
    ) throws -> Self? {
        guard !container.decodeNil() else {
            return nil
        }

        return try container.decode(Self.self)
    }

    public static func decode<Container: UnkeyedDecodingContainer>(
        from container: inout Container
    ) throws -> Self {
        try container.decode(Self.self)
    }

    public static func decodeIfPresent<Container: UnkeyedDecodingContainer>(
        from container: inout Container
    ) throws -> Self? {
        try container.decodeIfPresent(Self.self)
    }
}
