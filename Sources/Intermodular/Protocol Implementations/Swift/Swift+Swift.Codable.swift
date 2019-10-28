//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public struct EncodableSequence<Base: Sequence>: Encodable where Base.Element: Encodable {
    public let base: Base

    public init(base: Base) {
        self.base = base
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()

        try container.encode(contentsOf: base)
    }
}
