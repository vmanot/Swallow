//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension Encodable {
    public func encode<Container: KeyedEncodingContainerProtocol>(to container: inout Container, forKey key: Container.Key) throws {
        try container.encode(self, forKey: key)
    }

    public func encode<Container: SingleValueEncodingContainer>(to container: inout Container) throws {
        try container.encode(self)
    }

    public func encode(to container: inout SingleValueEncodingContainer) throws {
        try container.encode(self)
    }

    public func encode<Container: UnkeyedEncodingContainer>(to container: inout Container) throws {
        try container.encode(self)
    }

    public func encode(to container: inout UnkeyedEncodingContainer) throws {
        try container.encode(self)
    }
}
